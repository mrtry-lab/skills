#!/usr/bin/env bash
# agile-setup-project Step 4a: GitHub Projects v2 の Template から新 Project を copy する
#
# `copyProjectV2` mutation を実行し、新 Project の各種 ID (Project ID / Status field ID /
# 各 Status option ID / Iteration field ID / current iteration ID) を抽出して stdout に
# env-var 形式で出力する。出力は `generate-github-projects-ref.sh` にそのまま `eval` で
# 渡せる形式。
#
# Usage:
#   copy-from-template.sh \
#     --source-owner <SOURCE_ORG_OR_USER> \
#     --source-number <SOURCE_PROJECT_NUMBER> \
#     --dest-owner <DEST_ORG_OR_USER> \
#     --title "<NEW_PROJECT_TITLE>" \
#     [--include-draft-issues]
#
# Defaults:
#   source-owner = mrtry-lab
#   source-number = 3
#
# 必要な前提:
#   - gh CLI に 'project' / 'read:org' スコープ
#   - dest-owner への Project 作成権限
#   - jq インストール済み
#
# Exit codes:
#   0  成功 (env-var を stdout に出力)
#   1  引数不足 / 不正
#   2  source Project が見つからない / 権限なし
#   3  copyProjectV2 mutation 失敗
#   4  新 Project からの ID 抽出失敗 (template が壊れている / 期待する field がない)

set -euo pipefail

SOURCE_OWNER="mrtry-lab"
SOURCE_NUMBER="3"
DEST_OWNER=""
TITLE=""
INCLUDE_DRAFT="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-owner) SOURCE_OWNER="$2"; shift 2 ;;
    --source-number) SOURCE_NUMBER="$2"; shift 2 ;;
    --dest-owner) DEST_OWNER="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --include-draft-issues) INCLUDE_DRAFT="true"; shift ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# //;s/^#$//'
      exit 0
      ;;
    *) echo "ERROR: unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$DEST_OWNER" || -z "$TITLE" ]]; then
  echo "ERROR: --dest-owner and --title are required" >&2
  echo "       (defaults: --source-owner mrtry-lab --source-number 3)" >&2
  exit 1
fi

# --- 1. source Project の ID 取得 (organization と user の両方を試す)
log() { echo "[copy-from-template] $*" >&2; }

log "Resolving source Project: $SOURCE_OWNER/#$SOURCE_NUMBER"
SOURCE_ID=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) { projectV2(number: $num) { id template } }
    user(login: $owner) { projectV2(number: $num) { id template } }
  }' -f owner="$SOURCE_OWNER" -F num="$SOURCE_NUMBER" 2>/dev/null \
  | jq -r '.data.organization.projectV2.id // .data.user.projectV2.id // empty')

if [[ -z "$SOURCE_ID" ]]; then
  echo "ERROR: source Project $SOURCE_OWNER/#$SOURCE_NUMBER not found or no access" >&2
  exit 2
fi
log "Source Project ID: $SOURCE_ID"

# --- 2. source が template 設定済みかチェック (warn のみ、強制 copy はしない)
SOURCE_IS_TEMPLATE=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) { projectV2(number: $num) { template } }
    user(login: $owner) { projectV2(number: $num) { template } }
  }' -f owner="$SOURCE_OWNER" -F num="$SOURCE_NUMBER" 2>/dev/null \
  | jq -r '.data.organization.projectV2.template // .data.user.projectV2.template // false')

if [[ "$SOURCE_IS_TEMPLATE" != "true" ]]; then
  echo "ERROR: source Project $SOURCE_OWNER/#$SOURCE_NUMBER is not marked as a template" >&2
  echo "       Project Settings → 'Use as template' を有効化してから再実行してください" >&2
  exit 2
fi

# --- 3. dest owner の Node ID 取得
log "Resolving dest owner: $DEST_OWNER"
DEST_ID=$(gh api graphql -f query='
  query($owner: String!) {
    organization(login: $owner) { id }
    user(login: $owner) { id }
  }' -f owner="$DEST_OWNER" 2>/dev/null \
  | jq -r '.data.organization.id // .data.user.id // empty')

if [[ -z "$DEST_ID" ]]; then
  echo "ERROR: dest owner $DEST_OWNER not found" >&2
  exit 2
fi
log "Dest owner ID: $DEST_ID"

# --- 4. copyProjectV2 mutation 実行
log "Copying Project..."
COPY_RESULT=$(gh api graphql -f query='
  mutation($srcId: ID!, $destId: ID!, $title: String!, $includeDraft: Boolean!) {
    copyProjectV2(input: {
      projectId: $srcId
      ownerId: $destId
      title: $title
      includeDraftIssues: $includeDraft
    }) {
      projectV2 { id number url title }
    }
  }' -f srcId="$SOURCE_ID" -f destId="$DEST_ID" -f title="$TITLE" -F includeDraft="$INCLUDE_DRAFT" 2>&1)

if echo "$COPY_RESULT" | jq -e '.errors' >/dev/null 2>&1; then
  echo "ERROR: copyProjectV2 failed" >&2
  echo "$COPY_RESULT" >&2
  exit 3
fi

NEW_PROJECT_ID=$(echo "$COPY_RESULT" | jq -r '.data.copyProjectV2.projectV2.id')
NEW_NUMBER=$(echo "$COPY_RESULT" | jq -r '.data.copyProjectV2.projectV2.number')
NEW_URL=$(echo "$COPY_RESULT" | jq -r '.data.copyProjectV2.projectV2.url')
NEW_TITLE=$(echo "$COPY_RESULT" | jq -r '.data.copyProjectV2.projectV2.title')
log "New Project: $NEW_URL (number=$NEW_NUMBER, id=$NEW_PROJECT_ID)"

# --- 5. 新 Project の field 一覧を取得して ID 抽出
log "Extracting field IDs from new Project..."
FIELDS_JSON=$(gh api graphql -f query='
  query($owner: String!, $num: Int!) {
    organization(login: $owner) {
      projectV2(number: $num) {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
            ... on ProjectV2IterationField {
              id
              name
              configuration { iterations { id title startDate } }
            }
          }
        }
      }
    }
    user(login: $owner) {
      projectV2(number: $num) {
        fields(first: 50) {
          nodes {
            ... on ProjectV2SingleSelectField {
              id
              name
              options { id name }
            }
            ... on ProjectV2IterationField {
              id
              name
              configuration { iterations { id title startDate } }
            }
          }
        }
      }
    }
  }' -f owner="$DEST_OWNER" -F num="$NEW_NUMBER")

# org か user どちらかにデータが入る
FIELDS=$(echo "$FIELDS_JSON" | jq '.data.organization.projectV2.fields.nodes // .data.user.projectV2.fields.nodes')

STATUS_FIELD_ID=$(echo "$FIELDS" | jq -r '.[] | select(.name == "Status") | .id // empty')
ITERATION_FIELD_ID=$(echo "$FIELDS" | jq -r '.[] | select(.name == "Iteration") | .id // empty')

if [[ -z "$STATUS_FIELD_ID" ]]; then
  echo "ERROR: Status field not found in new Project (template が壊れている可能性)" >&2
  exit 4
fi

if [[ -z "$ITERATION_FIELD_ID" ]]; then
  echo "WARN: Iteration field not found in new Project (template が古い、または copy 時に欠落)" >&2
fi

# Status options を抽出
extract_option() {
  local name="$1"
  echo "$FIELDS" | jq -r --arg n "$name" \
    '.[] | select(.name == "Status") | .options[] | select(.name == $n) | .id // empty'
}

OPT_PLANNING=$(extract_option "In Planning")
OPT_PLAN_REFINEMENT=$(extract_option "In Plan Refinement")
OPT_PLAN_REVIEW=$(extract_option "In Plan Review")
OPT_READY=$(extract_option "Ready")
OPT_CODING=$(extract_option "In Coding Progress")
OPT_CODE_REVIEW=$(extract_option "In Code Review")
OPT_AWAITING_REVIEW=$(extract_option "Awaiting sprint review")
OPT_DONE=$(extract_option "Done")

# Iteration の current ID を抽出 (今日を含む iteration、無ければ最初の iteration)
CURRENT_ITERATION_ID=""
if [[ -n "$ITERATION_FIELD_ID" ]]; then
  TODAY=$(date -u +%Y-%m-%d)
  CURRENT_ITERATION_ID=$(echo "$FIELDS" | jq -r --arg today "$TODAY" '
    .[] | select(.name == "Iteration") | .configuration.iterations[]
    | select(.startDate <= $today) | .id' | tail -n1)

  if [[ -z "$CURRENT_ITERATION_ID" ]]; then
    CURRENT_ITERATION_ID=$(echo "$FIELDS" | jq -r '
      .[] | select(.name == "Iteration") | .configuration.iterations[0].id // empty')
  fi
fi

# --- 6. env-var 形式で stdout 出力
cat <<EOF
PROJECT_NAME="$NEW_TITLE"
OWNER="$DEST_OWNER"
NUMBER="$NEW_NUMBER"
PROJECT_ID="$NEW_PROJECT_ID"
PROJECT_URL="$NEW_URL"
STATUS_FIELD_ID="$STATUS_FIELD_ID"
OPT_PLANNING="$OPT_PLANNING"
OPT_PLAN_REFINEMENT="$OPT_PLAN_REFINEMENT"
OPT_PLAN_REVIEW="$OPT_PLAN_REVIEW"
OPT_READY="$OPT_READY"
OPT_CODING="$OPT_CODING"
OPT_CODE_REVIEW="$OPT_CODE_REVIEW"
OPT_AWAITING_REVIEW="$OPT_AWAITING_REVIEW"
OPT_DONE="$OPT_DONE"
ITERATION_FIELD_ID="$ITERATION_FIELD_ID"
CURRENT_ITERATION_ID="$CURRENT_ITERATION_ID"
EOF

log "Done. Capture the output via 'eval \"\$(copy-from-template.sh ...)\"' and pass to generate-github-projects-ref.sh"
