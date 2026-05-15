#!/usr/bin/env bash
# agile-* 共通: Issue の GitHub Projects Iteration を current iteration にセットする
#
# Usage:
#   set-issue-iteration.sh <issue-number> [app-name]
#
#   <issue-number>  対象 Issue の番号 (Project に追加済みであること)
#   [app-name]      複数アプリ運用時のアプリ識別子 (省略時は単一アプリ前提)
#                   例: "fieldnote" → github-projects.fieldnote.json を参照
#
# 必要な前提:
#   - .claude/skills/references/github-projects.json
#       (複数アプリの場合: github-projects.<app>.json) が配置済み
#   - github-projects.json の iteration_field.id / current_iteration_id が埋まっていること
#   - gh CLI に 'project' スコープ
#   - jq インストール済み
#
# Exit codes:
#   0  成功
#   1  引数不足 / 不正
#   2  github-projects.json が見つからない
#   3  iteration_field が未設定 (古い JSON で iteration セクションがない、または値が未充填)
#   4  Issue が Project に見つからない
#   5  gh project item-edit が失敗

set -euo pipefail

ISSUE="${1:-}"
APP_NAME="${2:-}"

if [[ -z "$ISSUE" ]]; then
  echo "Usage: $0 <issue-number> [app-name]" >&2
  exit 1
fi

# Resolve JSON filename based on app-name
if [[ -n "$APP_NAME" ]]; then
  JSON_NAME="github-projects.${APP_NAME}.json"
else
  JSON_NAME="github-projects.json"
fi

# Resolve github-projects.json (project scope first, then user scope)
GP_REF=""
for candidate in ".claude/skills/references/$JSON_NAME" "$HOME/.claude/skills/references/$JSON_NAME"; do
  if [[ -f "$candidate" ]]; then
    GP_REF="$candidate"
    break
  fi
done

if [[ -z "$GP_REF" ]]; then
  echo "ERROR: $JSON_NAME not found at .claude/skills/references/ (project or user scope)" >&2
  if [[ -n "$APP_NAME" ]]; then
    echo "       Run /agile-setup-project with --app $APP_NAME or check the app identifier." >&2
  else
    echo "       Run /agile-setup-project or /agile-update-skills first." >&2
  fi
  exit 2
fi

# Extract values via jq
OWNER=$(jq -r '.project.owner' "$GP_REF")
NUMBER=$(jq -r '.project.number' "$GP_REF")
PROJECT_ID=$(jq -r '.project.id' "$GP_REF")
ITERATION_FIELD_ID=$(jq -r '.iteration_field.id // empty' "$GP_REF")
CURRENT_ITERATION_ID=$(jq -r '.iteration_field.current_iteration_id // empty' "$GP_REF")

if [[ -z "$ITERATION_FIELD_ID" || -z "$CURRENT_ITERATION_ID" ]]; then
  echo "ERROR: iteration_field is not configured in $GP_REF" >&2
  echo "       Re-run /agile-setup-project to add Iteration field, or update the JSON manually." >&2
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

# Update Iteration
if gh project item-edit \
     --project-id "$PROJECT_ID" \
     --id "$ITEM_ID" \
     --field-id "$ITERATION_FIELD_ID" \
     --iteration-id "$CURRENT_ITERATION_ID" >/dev/null; then
  echo "ok: Issue #$ISSUE -> Iteration: @current"
else
  echo "ERROR: gh project item-edit failed for Issue #$ISSUE" >&2
  exit 5
fi
