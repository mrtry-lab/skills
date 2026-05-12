#!/usr/bin/env bash
# agile-* 共通: Issue の GitHub Projects Status を更新する
#
# Usage:
#   update-issue-status.sh <issue-number> <status-name>
#
#   <issue-number>  対象 Issue の番号 (Project に追加済みであること)
#   <status-name>   Status オプション名 (例: "In Coding Progress")
#                   有効値: In Planning | In Plan Refinement | In Plan Review
#                          | Ready | In Coding Progress | In Code Review | Done
#
# 必要な前提:
#   - .claude/skills/references/github-projects.json (または ~/.claude/.../github-projects.json) が配置済み
#   - gh CLI に 'project' スコープ
#   - jq インストール済み
#
# Exit codes:
#   0  成功
#   1  引数不足 / 不正
#   2  github-projects.json が見つからない
#   3  指定 Status が options に存在しない
#   4  Issue が Project に見つからない
#   5  gh project item-edit が失敗

set -euo pipefail

ISSUE="${1:-}"
STATUS_NAME="${2:-}"

if [[ -z "$ISSUE" || -z "$STATUS_NAME" ]]; then
  echo "Usage: $0 <issue-number> <status-name>" >&2
  exit 1
fi

# Resolve github-projects.json (project scope first, then user scope)
GP_REF=""
for candidate in ".claude/skills/references/github-projects.json" "$HOME/.claude/skills/references/github-projects.json"; do
  if [[ -f "$candidate" ]]; then
    GP_REF="$candidate"
    break
  fi
done

if [[ -z "$GP_REF" ]]; then
  echo "ERROR: github-projects.json not found at .claude/skills/references/ (project or user scope)" >&2
  echo "       Run /agile-setup-project or /agile-update-skills first." >&2
  exit 2
fi

# Extract values via jq
OWNER=$(jq -r '.project.owner' "$GP_REF")
NUMBER=$(jq -r '.project.number' "$GP_REF")
PROJECT_ID=$(jq -r '.project.id' "$GP_REF")
STATUS_FIELD_ID=$(jq -r '.status_field.id' "$GP_REF")
OPTION_ID=$(jq -r --arg name "$STATUS_NAME" '.status_field.options[$name] // empty' "$GP_REF")

if [[ -z "$OPTION_ID" ]]; then
  echo "ERROR: Status '$STATUS_NAME' not found in $GP_REF" >&2
  echo "       Valid options:" >&2
  jq -r '.status_field.options | keys[]' "$GP_REF" | sed 's/^/         - /' >&2
  exit 3
fi

# Resolve Project Item ID from Issue number
ITEM_ID=$(gh project item-list "$NUMBER" --owner "$OWNER" --format json --limit 500 \
  | jq -r --argjson num "$ISSUE" '.items[] | select(.content.number == $num) | .id' \
  | head -n1)

if [[ -z "$ITEM_ID" ]]; then
  echo "ERROR: Issue #$ISSUE not found in project $OWNER/#$NUMBER" >&2
  echo "       The issue may not be added to the project yet." >&2
  exit 4
fi

# Update Status
if gh project item-edit \
     --project-id "$PROJECT_ID" \
     --id "$ITEM_ID" \
     --field-id "$STATUS_FIELD_ID" \
     --single-select-option-id "$OPTION_ID" >/dev/null; then
  echo "ok: Issue #$ISSUE -> Status: $STATUS_NAME"
else
  echo "ERROR: gh project item-edit failed for Issue #$ISSUE" >&2
  exit 5
fi
