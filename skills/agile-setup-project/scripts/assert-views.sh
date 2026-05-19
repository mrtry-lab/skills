#!/usr/bin/env bash
# Project に Backlog / Sprint / Overview の 3 View が揃っているか検査
#
# Usage:
#   assert-views.sh --owner <ORG_OR_USER> --number <PROJECT_NUMBER>
#
# Exit code:
#   0  3 View 全て揃っている
#   1  いずれかの View がない
#   2  引数不足
#
# Stdout (exit 0): "ok: 3 Views present (Backlog, Sprint, Overview)"
# Stdout (exit 1): "MISSING_VIEWS=Sprint,Overview" の形式

set -euo pipefail

OWNER=""
NUMBER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --number) NUMBER="$2"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
  esac
done

[[ -z "$OWNER" || -z "$NUMBER" ]] && { echo "ERROR: --owner and --number required" >&2; exit 2; }

EXPECTED=("Backlog" "Sprint" "Overview")

RESP=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        views(first: 20) { nodes { name } }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        views(first: 20) { nodes { name } }
      }
    }
  }' -f owner="$OWNER" -F num="$NUMBER" 2>/dev/null || true)

ACTUAL=$(echo "$RESP" | jq -r '
  (.data.organization.projectV2.views.nodes // .data.user.projectV2.views.nodes // [])
  | .[].name')

MISSING=()
for v in "${EXPECTED[@]}"; do
  if ! echo "$ACTUAL" | grep -Fxq "$v"; then
    MISSING+=("$v")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "ok: 3 Views present (Backlog, Sprint, Overview)"
  exit 0
fi

CSV=$(IFS=,; echo "${MISSING[*]}")
echo "MISSING_VIEWS=$CSV"
exit 1
