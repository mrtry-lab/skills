#!/usr/bin/env bash
# Project の Workflows が期待設定通りか検査:
#   - Item closed: enabled (Status → Done に自動遷移)
#   - Auto-add to project: disabled (skill が明示的に追加する設計)
#   - Auto-close issue: disabled (Story Done で Backlog から消えないため)
#
# Usage:
#   assert-workflows.sh --owner <ORG_OR_USER> --number <PROJECT_NUMBER>
#
# Exit code:
#   0  全 Workflow が期待状態
#   1  いずれかが期待と異なる
#   2  引数不足
#
# Stdout (exit 0): "ok: Workflows configured correctly"
# Stdout (exit 1): "WORKFLOW_ITEM_CLOSED_DISABLED=true" or "WORKFLOW_AUTO_ADD_ENABLED=true" or "WORKFLOW_AUTO_CLOSE_ENABLED=true"

set -euo pipefail

OWNER=""
NUMBER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --number) NUMBER="$2"; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$OWNER" || -z "$NUMBER" ]] && { echo "ERROR: --owner and --number required" >&2; exit 2; }

RESP=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        workflows(first: 30) { nodes { name enabled } }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        workflows(first: 30) { nodes { name enabled } }
      }
    }
  }' -f owner="$OWNER" -F num="$NUMBER" 2>/dev/null || true)

WORKFLOWS=$(echo "$RESP" | jq '.data.organization.projectV2.workflows.nodes // .data.user.projectV2.workflows.nodes // []')

# 名前で取り出す (workflows() に表れない = "未設定" として扱う = enabled=false 相当)
get_workflow_enabled() {
  local name="$1"
  echo "$WORKFLOWS" | jq -r --arg n "$name" '.[] | select(.name == $n) | .enabled // false' | head -n1
}

ITEM_CLOSED=$(get_workflow_enabled "Item closed")
AUTO_ADD=$(get_workflow_enabled "Auto-add to project")
AUTO_CLOSE=$(get_workflow_enabled "Auto-close issue")

# 空 = workflow が一覧に出てこない (= 未設定で disabled) として扱う
[[ -z "$ITEM_CLOSED" ]] && ITEM_CLOSED="false"
[[ -z "$AUTO_ADD" ]] && AUTO_ADD="false"
[[ -z "$AUTO_CLOSE" ]] && AUTO_CLOSE="false"

FAIL=0
[[ "$ITEM_CLOSED" != "true" ]] && { echo "WORKFLOW_ITEM_CLOSED_DISABLED=true"; FAIL=1; }
[[ "$AUTO_ADD" == "true" ]] && { echo "WORKFLOW_AUTO_ADD_ENABLED=true"; FAIL=1; }
[[ "$AUTO_CLOSE" == "true" ]] && { echo "WORKFLOW_AUTO_CLOSE_ENABLED=true"; FAIL=1; }

if [[ "$FAIL" -eq 0 ]]; then
  echo "ok: Workflows configured correctly (Item closed=ON, Auto-add/Auto-close=OFF)"
  exit 0
fi
exit 1
