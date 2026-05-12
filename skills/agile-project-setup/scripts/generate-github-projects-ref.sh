#!/usr/bin/env bash
# agile-project-setup Step 7: github-projects.md 生成
#
# 必須 env vars:
#   PROJECT_NAME      Project の表示名
#   OWNER             GitHub Org / User
#   NUMBER            Project Number (URL 末尾の数字)
#   PROJECT_ID        Project ID (PVT_...)
#   STATUS_FIELD_ID   Status フィールド ID (PVTSSF_...)
#   OPT_PLANNING            In Planning option ID
#   OPT_PLAN_REFINEMENT     In Plan Refinement option ID
#   OPT_PLAN_REVIEW         In Plan Review option ID
#   OPT_READY               Ready option ID
#   OPT_CODING              In Coding Progress option ID
#   OPT_CODE_REVIEW         In Code Review option ID
#   OPT_DONE                Done option ID
#
# 任意:
#   OUTPUT            出力先パス (default: .claude/skills/references/github-projects.md)

set -euo pipefail

OUTPUT="${OUTPUT:-.claude/skills/references/github-projects.md}"

required=(PROJECT_NAME OWNER NUMBER PROJECT_ID STATUS_FIELD_ID \
          OPT_PLANNING OPT_PLAN_REFINEMENT OPT_PLAN_REVIEW OPT_READY \
          OPT_CODING OPT_CODE_REVIEW OPT_DONE)

missing=()
for var in "${required[@]}"; do
  [[ -z "${!var:-}" ]] && missing+=("$var")
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: missing required env vars: ${missing[*]}" >&2
  echo "       See header of $0 for the full list." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

curl -fsSL https://raw.githubusercontent.com/mrtry-lab/skills/main/shared/references/github-projects.md.template \
  -o "$OUTPUT"

if sed --version >/dev/null 2>&1; then
  inplace() { sed -i "$@"; }
else
  inplace() { sed -i '' "$@"; }
fi

inplace \
  -e "s|<YOUR_PROJECT_NAME>|$PROJECT_NAME|g" \
  -e "s|<YOUR_GITHUB_ORG>|$OWNER|g" \
  -e "s|<YOUR_PROJECT_NUMBER>|$NUMBER|g" \
  -e "s|<YOUR_PROJECT_ID>|$PROJECT_ID|g" \
  -e "s|<YOUR_STATUS_FIELD_ID>|$STATUS_FIELD_ID|g" \
  -e "s|<STATUS_OPTION_ID_IN_PLANNING>|$OPT_PLANNING|g" \
  -e "s|<STATUS_OPTION_ID_IN_PLAN_REFINEMENT>|$OPT_PLAN_REFINEMENT|g" \
  -e "s|<STATUS_OPTION_ID_IN_PLAN_REVIEW>|$OPT_PLAN_REVIEW|g" \
  -e "s|<STATUS_OPTION_ID_READY>|$OPT_READY|g" \
  -e "s|<STATUS_OPTION_ID_IN_CODING_PROGRESS>|$OPT_CODING|g" \
  -e "s|<STATUS_OPTION_ID_IN_CODE_REVIEW>|$OPT_CODE_REVIEW|g" \
  -e "s|<STATUS_OPTION_ID_DONE>|$OPT_DONE|g" \
  "$OUTPUT"

if grep -nE '<(YOUR_|STATUS_OPTION_)' "$OUTPUT" >/dev/null; then
  echo "WARN: unreplaced placeholders remain:" >&2
  grep -nE '<(YOUR_|STATUS_OPTION_)' "$OUTPUT" >&2
  exit 1
fi

echo "ok: $OUTPUT"
