#!/usr/bin/env bash
# Project に Iteration field が存在し、duration=180 で current iteration が 1 件以上あるか検査
#
# Usage:
#   assert-iteration-field.sh --owner <ORG_OR_USER> --number <PROJECT_NUMBER>
#
# Exit code:
#   0  Iteration field が期待通り (duration=180、iterations >= 1)
#   1  Iteration field がない / duration が違う / iteration 未生成
#   2  引数不足
#
# Stdout (exit 0): "ok: Iteration field (duration=180, iterations=N)"
# Stdout (exit 1): "ITERATION_FIELD_MISSING=true" or "ITERATION_DURATION_MISMATCH=<actual>" or "ITERATION_NO_CURRENT=true"

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

EXPECTED_DURATION=180

RESP=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        field(name: "Iteration") {
          ... on ProjectV2IterationField {
            id
            configuration { duration iterations { id } }
          }
        }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        field(name: "Iteration") {
          ... on ProjectV2IterationField {
            id
            configuration { duration iterations { id } }
          }
        }
      }
    }
  }' -f owner="$OWNER" -F num="$NUMBER" 2>/dev/null || true)

FIELD=$(echo "$RESP" | jq '.data.organization.projectV2.field // .data.user.projectV2.field')

if [[ "$FIELD" == "null" || -z "$FIELD" ]]; then
  echo "ITERATION_FIELD_MISSING=true"
  exit 1
fi

DURATION=$(echo "$FIELD" | jq -r '.configuration.duration // 0')
ITER_COUNT=$(echo "$FIELD" | jq -r '.configuration.iterations | length')

if [[ "$DURATION" != "$EXPECTED_DURATION" ]]; then
  echo "ITERATION_DURATION_MISMATCH=$DURATION (expected $EXPECTED_DURATION)"
  exit 1
fi

if [[ "$ITER_COUNT" -lt 1 ]]; then
  echo "ITERATION_NO_CURRENT=true"
  exit 1
fi

echo "ok: Iteration field (duration=$DURATION, iterations=$ITER_COUNT)"
exit 0
