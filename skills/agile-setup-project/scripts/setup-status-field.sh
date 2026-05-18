#!/usr/bin/env bash
# agile-setup-project Step 5: Status フィールド + 8 オプション作成
#
# Usage:
#   setup-status-field.sh --owner <ORG> --project <NUMBER>
#
# 既存の Status フィールドがあれば作成をスキップ (オプション不足の場合は Web UI 補完を案内)

set -euo pipefail

OWNER=""
PROJECT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OWNER" || -z "$PROJECT" ]]; then
  echo "ERROR: --owner and --project are required" >&2
  exit 1
fi

EXPECTED_OPTIONS=("In Planning" "In Plan Refinement" "In Plan Review" "Ready" "In Coding Progress" "In Code Review" "Awaiting sprint review" "Done")

# Check whether Status field already exists
EXISTING=$(gh project field-list "$PROJECT" --owner "$OWNER" --format json --jq '.fields[] | select(.name == "Status") | .id' || true)

if [[ -n "$EXISTING" ]]; then
  echo "INFO: Status field already exists (id=$EXISTING)"
  echo "      Verify the 8 options are present:"
  for opt in "${EXPECTED_OPTIONS[@]}"; do
    echo "        - $opt"
  done
  echo "      gh CLI cannot add options to an existing single-select field."
  echo "      Missing options must be added via Web UI."
  exit 0
fi

OPTIONS_CSV=$(IFS=, ; echo "${EXPECTED_OPTIONS[*]}")

gh project field-create "$PROJECT" --owner "$OWNER" \
  --name "Status" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "$OPTIONS_CSV"

echo "ok: Status field created with 8 options"
