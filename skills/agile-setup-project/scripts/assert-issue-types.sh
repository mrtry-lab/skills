#!/usr/bin/env bash
# Organization に agile-* スキル群が必要とする Issue Type 4 件
# (Epic / Story / Implementation Plan / Task) が登録されているか検査
#
# Usage:
#   assert-issue-types.sh --org <ORG>
#
# Exit code:
#   0  4 種類すべて登録済み
#   1  いずれかが未登録
#   2  引数不足 or Org が見つからない
#
# Stdout (exit 0): "ok: 4 Issue Types registered (Epic, Story, Implementation Plan, Task)"
# Stdout (exit 1): "MISSING_ISSUE_TYPES=Story,Task" の形式

set -euo pipefail

ORG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$ORG" ]] && { echo "ERROR: --org required" >&2; exit 2; }

EXPECTED=("Epic" "Story" "Implementation Plan" "Task")

RESP=$(gh api graphql -f query='
  query($org: String!) {
    organization(login: $org) {
      issueTypes(first: 50) { nodes { name } }
    }
  }' -f org="$ORG" 2>/dev/null || true)

if echo "$RESP" | jq -e '.data.organization == null' >/dev/null 2>&1; then
  echo "ERROR: Organization '$ORG' not found or no access" >&2
  exit 2
fi

ACTUAL=$(echo "$RESP" | jq -r '.data.organization.issueTypes.nodes[]?.name // empty')

MISSING=()
for t in "${EXPECTED[@]}"; do
  if ! echo "$ACTUAL" | grep -Fxq "$t"; then
    MISSING+=("$t")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "ok: 4 Issue Types registered (Epic, Story, Implementation Plan, Task)"
  exit 0
fi

CSV=$(IFS=,; echo "${MISSING[*]}")
echo "MISSING_ISSUE_TYPES=$CSV"
exit 1
