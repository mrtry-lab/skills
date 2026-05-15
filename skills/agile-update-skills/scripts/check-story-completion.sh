#!/usr/bin/env bash
# agile-* 共通: Story 配下の Plan/Task が全 Done か判定し、
# `--detect-only` モードなら判定結果を出力するだけ、
# それ以外なら Story Status を `Awaiting sprint review` に遷移する。
#
# `agile-sprint-review` の Step 1 (lazy scan) では --detect-only で候補列挙、
# その後ユーザー承認を得たうえで本適用 (--detect-only なし) で呼び直す 2 段構え。
#
# Usage:
#   check-story-completion.sh <story-issue-number> [--detect-only] [app-name]
#
#   <story-issue-number>  対象 Story の番号
#   --detect-only         判定のみ。Status 遷移は行わず、stdout に
#                         "READY_TO_PROMOTE #N <title>" を出して exit 0
#                         (子が全 Done で promote 対象なら)。それ以外は
#                         silent exit 0
#   [app-name]            複数アプリ運用時のアプリ識別子 (省略時は単一アプリ前提)
#
# 必要な前提:
#   - .claude/skills/references/github-projects.json
#       (複数アプリの場合: github-projects.<app>.json) が配置済み
#   - gh CLI に 'project' / 'repo' / 'read:org' スコープ
#   - jq インストール済み
#
# Exit codes:
#   0  no-op or 遷移成功
#   1  引数不足
#   2  github-projects.json が見つからない
#   3  対象 Issue が見つからない / Story ではない / Project に未追加
#   4  Status 遷移失敗

set -euo pipefail

ISSUE=""
APP_NAME=""
DETECT_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --detect-only) DETECT_ONLY=1 ;;
    *)
      if [[ -z "$ISSUE" ]]; then
        ISSUE="$arg"
      elif [[ -z "$APP_NAME" ]]; then
        APP_NAME="$arg"
      fi
      ;;
  esac
done

if [[ -z "$ISSUE" ]]; then
  echo "Usage: $0 <story-issue-number> [--detect-only] [app-name]" >&2
  exit 1
fi

# Resolve JSON filename based on app-name
if [[ -n "$APP_NAME" ]]; then
  JSON_NAME="github-projects.${APP_NAME}.json"
else
  JSON_NAME="github-projects.json"
fi

# Resolve github-projects.json
GP_REF=""
for candidate in ".claude/skills/references/$JSON_NAME" "$HOME/.claude/skills/references/$JSON_NAME"; do
  if [[ -f "$candidate" ]]; then
    GP_REF="$candidate"
    break
  fi
done

if [[ -z "$GP_REF" ]]; then
  echo "ERROR: $JSON_NAME not found" >&2
  exit 2
fi

OWNER=$(jq -r '.project.owner' "$GP_REF")
NUMBER=$(jq -r '.project.number' "$GP_REF")
PROJECT_ID=$(jq -r '.project.id' "$GP_REF")

# Resolve repository (we need it for issue lookup)
# Iterate items to find the repo for this issue
REPO=$(gh project item-list "$NUMBER" --owner "$OWNER" --format json --limit 500 \
  | jq -r --argjson num "$ISSUE" '.items[] | select(.content.number == $num) | .content.repository' \
  | head -n1)

if [[ -z "$REPO" || "$REPO" == "null" ]]; then
  echo "ERROR: Issue #$ISSUE not found in project $OWNER/#$NUMBER" >&2
  exit 3
fi

# Fetch issue details via GraphQL (we need: issue type, current Status, sub-issues with their statuses)
QUERY='
query($owner: String!, $repo: String!, $num: Int!) {
  repository(owner: $owner, name: $repo) {
    issue(number: $num) {
      issueType { name }
      state
      subIssues(first: 50) {
        nodes {
          number
          state
          repository { nameWithOwner }
        }
      }
      projectItems(first: 10) {
        nodes {
          project { number }
          fieldValueByName(name: "Status") {
            ... on ProjectV2ItemFieldSingleSelectValue { name }
          }
        }
      }
    }
  }
}'

# REPO is like "owner/name"
REPO_OWNER="${REPO%%/*}"
REPO_NAME="${REPO#*/}"

RESPONSE=$(gh api graphql -f query="$QUERY" \
  -f owner="$REPO_OWNER" -f repo="$REPO_NAME" \
  -F num="$ISSUE")

ISSUE_TYPE=$(echo "$RESPONSE" | jq -r '.data.repository.issue.issueType.name // "null"')

if [[ "$ISSUE_TYPE" != "Story" ]]; then
  # not a Story - silently no-op
  exit 0
fi

# Get current Status in our Project
CURRENT_STATUS=$(echo "$RESPONSE" | jq -r --argjson pn "$NUMBER" '.data.repository.issue.projectItems.nodes[] | select(.project.number == $pn) | .fieldValueByName.name // "null"')

if [[ "$CURRENT_STATUS" != "In Coding Progress" ]]; then
  # Story is not in active implementation state — skip
  exit 0
fi

# Count sub-issues by state
SUB_ISSUE_COUNT=$(echo "$RESPONSE" | jq -r '.data.repository.issue.subIssues.nodes | length')

if [[ "$SUB_ISSUE_COUNT" -eq 0 ]]; then
  # No sub-issues — Story can't be auto-promoted from completion
  exit 0
fi

# For each sub-issue, check its Project Status. If all sub-issues have Status=Done, promote.
ALL_DONE=true
for sub_num in $(echo "$RESPONSE" | jq -r '.data.repository.issue.subIssues.nodes[].number'); do
  sub_status=$(gh api graphql -f query='
    query($owner: String!, $repo: String!, $num: Int!) {
      repository(owner: $owner, name: $repo) {
        issue(number: $num) {
          projectItems(first: 10) {
            nodes {
              project { number }
              fieldValueByName(name: "Status") {
                ... on ProjectV2ItemFieldSingleSelectValue { name }
              }
            }
          }
        }
      }
    }' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F num="$sub_num" \
    --jq ".data.repository.issue.projectItems.nodes[] | select(.project.number == $NUMBER) | .fieldValueByName.name // \"null\"")

  if [[ "$sub_status" != "Done" ]]; then
    ALL_DONE=false
    break
  fi
done

if [[ "$ALL_DONE" != "true" ]]; then
  # at least one child is not Done — no-op
  exit 0
fi

# All children are Done — either detect-only or promote
STORY_TITLE=$(gh api "repos/$REPO/issues/$ISSUE" --jq '.title')

if [[ "$DETECT_ONLY" -eq 1 ]]; then
  # detect-only mode: emit the candidate marker and exit
  echo "READY_TO_PROMOTE #$ISSUE $STORY_TITLE"
  exit 0
fi

# Promote Story to Awaiting sprint review
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/update-issue-status.sh" "$ISSUE" "Awaiting sprint review" ${APP_NAME:+"$APP_NAME"} >/dev/null || {
  echo "ERROR: failed to update Story #$ISSUE to 'Awaiting sprint review'" >&2
  exit 4
}

echo "promoted: Story #$ISSUE -> Awaiting sprint review (all sub-issues Done)"
