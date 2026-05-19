#!/usr/bin/env bash
# Issue が agile-* スキル群が期待する状態か検査:
#   - Issue Type (Epic / Story / Implementation Plan / Task)
#   - Project Status
#   - 親 Issue リンク (sub-issue 関係)
#   - Iteration field (Plan/Task の場合)
#
# Usage:
#   assert-issue-state.sh <issue-number> --repo <owner/repo> --project-owner <ORG> --project-number <NUMBER> \
#     [--type <Type>] [--status <Status>] [--parent <parent-issue-number>] [--has-iteration|--no-iteration]
#
# Exit code:
#   0  全 assert 通過
#   1  いずれか不一致
#   2  引数不足 / Issue が見つからない
#
# Stdout (exit 0): "ok: Issue #N state matches expectations"
# Stdout (exit 1): "MISMATCH_TYPE=expected=X actual=Y" 等の env-var 形式

set -euo pipefail

ISSUE=""
REPO=""
PROJECT_OWNER=""
PROJECT_NUMBER=""
EXPECTED_TYPE=""
EXPECTED_STATUS=""
EXPECTED_PARENT=""
ITERATION_CHECK=""  # "has" | "no" | ""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --project-owner) PROJECT_OWNER="$2"; shift 2 ;;
    --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
    --type) EXPECTED_TYPE="$2"; shift 2 ;;
    --status) EXPECTED_STATUS="$2"; shift 2 ;;
    --parent) EXPECTED_PARENT="$2"; shift 2 ;;
    --has-iteration) ITERATION_CHECK="has"; shift ;;
    --no-iteration) ITERATION_CHECK="no"; shift ;;
    -h|--help) sed -n '2,18p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    -*) echo "ERROR: unknown arg: $1" >&2; exit 2 ;;
    *)
      if [[ -z "$ISSUE" ]]; then ISSUE="$1"; fi
      shift
      ;;
  esac
done

[[ -z "$ISSUE" ]] && { echo "ERROR: <issue-number> required" >&2; exit 2; }
[[ -z "$REPO" ]] && { echo "ERROR: --repo required" >&2; exit 2; }

REPO_OWNER="${REPO%%/*}"
REPO_NAME="${REPO#*/}"

# Issue + Project items を一気に取得
RESP=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $num: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $num) {
        issueType { name }
        parent { number }
        projectItems(first: 20) {
          nodes {
            project { number owner { ... on Organization { login } ... on User { login } } }
            fieldValueByName(name: "Status") {
              ... on ProjectV2ItemFieldSingleSelectValue { name }
            }
            iterField: fieldValueByName(name: "Iteration") {
              ... on ProjectV2ItemFieldIterationValue { title iterationId }
            }
          }
        }
      }
    }
  }' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F num="$ISSUE" 2>/dev/null || true)

ISSUE_DATA=$(echo "$RESP" | jq '.data.repository.issue // null')
if [[ "$ISSUE_DATA" == "null" ]]; then
  echo "ERROR: Issue $REPO#$ISSUE not found" >&2
  exit 2
fi

ACTUAL_TYPE=$(echo "$ISSUE_DATA" | jq -r '.issueType.name // ""')
ACTUAL_PARENT=$(echo "$ISSUE_DATA" | jq -r '.parent.number // empty')

# Project item を絞り込み
if [[ -n "$PROJECT_OWNER" && -n "$PROJECT_NUMBER" ]]; then
  PROJECT_ITEM=$(echo "$ISSUE_DATA" | jq --arg o "$PROJECT_OWNER" --argjson n "$PROJECT_NUMBER" \
    '.projectItems.nodes[] | select(.project.owner.login == $o and .project.number == $n)')
else
  PROJECT_ITEM=$(echo "$ISSUE_DATA" | jq '.projectItems.nodes[0]')
fi

ACTUAL_STATUS=$(echo "$PROJECT_ITEM" | jq -r '.fieldValueByName.name // ""')
ACTUAL_ITERATION=$(echo "$PROJECT_ITEM" | jq -r '.iterField.title // ""')

FAIL=0

if [[ -n "$EXPECTED_TYPE" && "$ACTUAL_TYPE" != "$EXPECTED_TYPE" ]]; then
  echo "MISMATCH_TYPE=expected=$EXPECTED_TYPE actual=$ACTUAL_TYPE"
  FAIL=1
fi

if [[ -n "$EXPECTED_STATUS" && "$ACTUAL_STATUS" != "$EXPECTED_STATUS" ]]; then
  echo "MISMATCH_STATUS=expected=$EXPECTED_STATUS actual=$ACTUAL_STATUS"
  FAIL=1
fi

if [[ -n "$EXPECTED_PARENT" && "$ACTUAL_PARENT" != "$EXPECTED_PARENT" ]]; then
  echo "MISMATCH_PARENT=expected=$EXPECTED_PARENT actual=$ACTUAL_PARENT"
  FAIL=1
fi

case "$ITERATION_CHECK" in
  has)
    if [[ -z "$ACTUAL_ITERATION" ]]; then
      echo "MISMATCH_ITERATION=expected=present actual=未設定"
      FAIL=1
    fi
    ;;
  no)
    if [[ -n "$ACTUAL_ITERATION" ]]; then
      echo "MISMATCH_ITERATION=expected=未設定 actual=$ACTUAL_ITERATION"
      FAIL=1
    fi
    ;;
esac

if [[ "$FAIL" -eq 0 ]]; then
  echo "ok: Issue #$ISSUE state matches expectations (type=$ACTUAL_TYPE, status=$ACTUAL_STATUS, parent=$ACTUAL_PARENT, iteration=$ACTUAL_ITERATION)"
  exit 0
fi
exit 1
