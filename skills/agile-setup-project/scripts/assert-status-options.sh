#!/usr/bin/env bash
# Project の Status field に 8 オプションが揃っているか検査する
#
# Usage:
#   assert-status-options.sh --owner <ORG_OR_USER> --number <PROJECT_NUMBER>
#
# Exit code:
#   0  全 8 オプションが揃っている
#   1  Project / Status field が見つからない or オプション不足
#   2  引数不足
#
# Stdout (exit 0): "ok: 8 Status options"
# Stdout (exit 1): "MISSING_STATUS_OPTIONS=opt1,opt2,..." の形式

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

EXPECTED=("In Planning" "In Plan Refinement" "In Plan Review" "Ready" "In Coding Progress" "In Code Review" "Awaiting sprint review" "Done")

# gh api は union 片方が NOT_FOUND だと non-zero exit するので || true で吸収
RESP=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        field(name: "Status") {
          ... on ProjectV2SingleSelectField { options { name } }
        }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        field(name: "Status") {
          ... on ProjectV2SingleSelectField { options { name } }
        }
      }
    }
  }' -f owner="$OWNER" -F num="$NUMBER" 2>/dev/null || true)

ACTUAL=$(echo "$RESP" | jq -r '
  (.data.organization.projectV2.field.options // .data.user.projectV2.field.options // [])
  | .[].name')

if [[ -z "$ACTUAL" ]]; then
  echo "STATUS_FIELD_MISSING=true"
  exit 1
fi

MISSING=()
for opt in "${EXPECTED[@]}"; do
  if ! echo "$ACTUAL" | grep -Fxq "$opt"; then
    MISSING+=("$opt")
  fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "ok: 8 Status options"
  exit 0
fi

CSV=$(IFS=,; echo "${MISSING[*]}")
echo "MISSING_STATUS_OPTIONS=$CSV"
exit 1
