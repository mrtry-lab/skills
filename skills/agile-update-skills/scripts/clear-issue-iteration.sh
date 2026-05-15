#!/usr/bin/env bash
# agile-* 共通: Issue の Project Item から Iteration field 値をクリアする
#
# `agile-sprint-review` の OK 処理から呼ばれる想定。
# Story を Done にした後、配下の Plan/Task の iteration を外して Sprint Board から落とす用途。
#
# Usage:
#   clear-issue-iteration.sh <issue-number> [app-name]
#
#   <issue-number>  対象 Issue の番号 (Project に追加済みであること)
#   [app-name]      複数アプリ運用時のアプリ識別子 (省略時は単一アプリ前提)
#
# 必要な前提:
#   - .claude/skills/references/github-projects.json
#       (複数アプリの場合: github-projects.<app>.json) が配置済み
#   - github-projects.json の iteration_field.id が埋まっていること
#   - gh CLI に 'project' スコープ
#   - jq インストール済み
#
# Exit codes:
#   0  クリア成功
#   1  引数不足
#   2  github-projects.json が見つからない
#   3  iteration_field が未設定
#   4  Issue が Project に見つからない
#   5  GraphQL mutation 失敗

set -euo pipefail

ISSUE="${1:-}"
APP_NAME="${2:-}"

if [[ -z "$ISSUE" ]]; then
  echo "Usage: $0 <issue-number> [app-name]" >&2
  exit 1
fi

if [[ -n "$APP_NAME" ]]; then
  JSON_NAME="github-projects.${APP_NAME}.json"
else
  JSON_NAME="github-projects.json"
fi

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
ITERATION_FIELD_ID=$(jq -r '.iteration_field.id // empty' "$GP_REF")

if [[ -z "$ITERATION_FIELD_ID" ]]; then
  echo "ERROR: iteration_field.id is not configured in $GP_REF" >&2
  exit 3
fi

ITEM_ID=$(gh project item-list "$NUMBER" --owner "$OWNER" --format json --limit 500 \
  | jq -r --argjson num "$ISSUE" '.items[] | select(.content.number == $num) | .id' \
  | head -n1)

if [[ -z "$ITEM_ID" ]]; then
  echo "ERROR: Issue #$ISSUE not found in project $OWNER/#$NUMBER" >&2
  exit 4
fi

if gh api graphql -f query='
    mutation($p: ID!, $i: ID!, $f: ID!) {
      clearProjectV2ItemFieldValue(input: {
        projectId: $p
        itemId: $i
        fieldId: $f
      }) {
        projectV2Item { id }
      }
    }' -f p="$PROJECT_ID" -f i="$ITEM_ID" -f f="$ITERATION_FIELD_ID" >/dev/null; then
  echo "ok: Issue #$ISSUE -> Iteration cleared"
else
  echo "ERROR: clearProjectV2ItemFieldValue failed for Issue #$ISSUE" >&2
  exit 5
fi
