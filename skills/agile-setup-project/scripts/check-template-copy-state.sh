#!/usr/bin/env bash
# agile-setup-project Step 4a: Template copy 直後の Project の引き継ぎ状況を確認する
#
# Status options 8 件 / Iteration field / Workflows / Views の引き継ぎを判定し、
# 不足項目を stdout に env-var 形式で列挙する。
#
# 出力例:
#   ALL_OK=false
#   MISSING_STATUS_OPTIONS=""
#   MISSING_ITERATION_FIELD=""
#   MISSING_WORKFLOW_ITEM_CLOSED=""
#   EXTRA_WORKFLOW_AUTO_ADD_TO_PROJECT="true"
#   EXTRA_WORKFLOW_AUTO_CLOSE_ISSUE="true"
#   MISSING_VIEWS="Sprint"
#
# Usage:
#   check-template-copy-state.sh --owner <ORG> --number <PROJECT_NUMBER>
#
# 必要な前提:
#   - gh CLI に 'project' / 'read:org' スコープ
#   - jq インストール済み

set -euo pipefail

OWNER=""
NUMBER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --number) NUMBER="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,18p' "$0" | sed 's/^# //;s/^#$//'
      exit 0
      ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$OWNER" || -z "$NUMBER" ]]; then
  echo "ERROR: --owner and --number are required" >&2
  exit 1
fi

# Project の構成を一気に取得 (organization / user 両方試行)
# gh api graphql は片方の union が NOT_FOUND を返すと non-zero exit するので無視する (|| true)
PROJECT_JSON=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField { name options { name } }
            ... on ProjectV2IterationField { name configuration { duration iterations { id } } }
          }
        }
        views(first: 20) { nodes { name } }
        workflows(first: 30) { nodes { name enabled } }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField { name options { name } }
            ... on ProjectV2IterationField { name configuration { duration iterations { id } } }
          }
        }
        views(first: 20) { nodes { name } }
        workflows(first: 30) { nodes { name enabled } }
      }
    }
  }' -f owner="$OWNER" -F num="$NUMBER" 2>/dev/null || true)

PROJECT=$(echo "$PROJECT_JSON" | jq '.data.organization.projectV2 // .data.user.projectV2')

if [[ "$PROJECT" == "null" || -z "$PROJECT" ]]; then
  echo "ERROR: Project $OWNER/#$NUMBER not found or no access" >&2
  exit 2
fi

# --- 1. Status options check
EXPECTED_OPTIONS=("In Planning" "In Plan Refinement" "In Plan Review" "Ready" "In Coding Progress" "In Code Review" "Awaiting sprint review" "Done")
ACTUAL_OPTIONS=$(echo "$PROJECT" | jq -r '.fields.nodes[] | select(.name == "Status") | .options[].name' 2>/dev/null || echo "")

MISSING_STATUS=()
for opt in "${EXPECTED_OPTIONS[@]}"; do
  if ! echo "$ACTUAL_OPTIONS" | grep -Fxq "$opt"; then
    MISSING_STATUS+=("$opt")
  fi
done

# --- 2. Iteration field check
ITER_FIELD_PRESENT=$(echo "$PROJECT" | jq -r '[.fields.nodes[] | select(.name == "Iteration")] | length > 0')
ITER_DURATION=$(echo "$PROJECT" | jq -r '.fields.nodes[] | select(.name == "Iteration") | .configuration.duration // 0')
ITER_HAS_CURRENT=$(echo "$PROJECT" | jq -r '.fields.nodes[] | select(.name == "Iteration") | (.configuration.iterations | length > 0)' 2>/dev/null || echo "false")

# --- 3. Workflows check
WORKFLOW_ITEM_CLOSED_ENABLED=$(echo "$PROJECT" | jq -r '.workflows.nodes[] | select(.name == "Item closed") | .enabled' 2>/dev/null || echo "false")
WORKFLOW_AUTO_ADD_ENABLED=$(echo "$PROJECT" | jq -r '.workflows.nodes[] | select(.name == "Auto-add to project") | .enabled' 2>/dev/null || echo "false")
WORKFLOW_AUTO_CLOSE_ENABLED=$(echo "$PROJECT" | jq -r '.workflows.nodes[] | select(.name == "Auto-close issue") | .enabled' 2>/dev/null || echo "false")

# --- 4. Views check
EXPECTED_VIEWS=("Backlog" "Sprint" "Overview")
ACTUAL_VIEWS=$(echo "$PROJECT" | jq -r '.views.nodes[].name' 2>/dev/null || echo "")
MISSING_VIEWS=()
for v in "${EXPECTED_VIEWS[@]}"; do
  if ! echo "$ACTUAL_VIEWS" | grep -Fxq "$v"; then
    MISSING_VIEWS+=("$v")
  fi
done

# --- 5. 結果 stdout
MISSING_STATUS_CSV=$(IFS=,; echo "${MISSING_STATUS[*]:-}")
MISSING_VIEWS_CSV=$(IFS=,; echo "${MISSING_VIEWS[*]:-}")

# ALL_OK 判定
ALL_OK="true"
[[ ${#MISSING_STATUS[@]} -gt 0 ]] && ALL_OK="false"
[[ "$ITER_FIELD_PRESENT" != "true" ]] && ALL_OK="false"
[[ "$ITER_HAS_CURRENT" != "true" ]] && ALL_OK="false"
[[ "$WORKFLOW_ITEM_CLOSED_ENABLED" != "true" ]] && ALL_OK="false"
[[ "$WORKFLOW_AUTO_ADD_ENABLED" == "true" ]] && ALL_OK="false"
[[ "$WORKFLOW_AUTO_CLOSE_ENABLED" == "true" ]] && ALL_OK="false"
[[ ${#MISSING_VIEWS[@]} -gt 0 ]] && ALL_OK="false"

cat <<EOF
ALL_OK="$ALL_OK"
MISSING_STATUS_OPTIONS="$MISSING_STATUS_CSV"
ITERATION_FIELD_PRESENT="$ITER_FIELD_PRESENT"
ITERATION_DURATION="$ITER_DURATION"
ITERATION_HAS_CURRENT="$ITER_HAS_CURRENT"
WORKFLOW_ITEM_CLOSED_ENABLED="$WORKFLOW_ITEM_CLOSED_ENABLED"
WORKFLOW_AUTO_ADD_ENABLED="$WORKFLOW_AUTO_ADD_ENABLED"
WORKFLOW_AUTO_CLOSE_ENABLED="$WORKFLOW_AUTO_CLOSE_ENABLED"
MISSING_VIEWS="$MISSING_VIEWS_CSV"
EOF
