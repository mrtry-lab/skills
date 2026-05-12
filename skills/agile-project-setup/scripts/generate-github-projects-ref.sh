#!/usr/bin/env bash
# agile-project-setup Step 7: github-projects.json 生成
#
# 必須 env vars:
#   PROJECT_NAME      Project の表示名
#   OWNER             GitHub Org / User
#   NUMBER            Project Number
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
#   OUTPUT            出力先パス (default: .claude/skills/references/github-projects.json)

set -euo pipefail

OUTPUT="${OUTPUT:-.claude/skills/references/github-projects.json}"

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

TEMPLATE_URL="https://raw.githubusercontent.com/mrtry-lab/skills/main/shared/references/github-projects.json.template"

curl -fsSL "$TEMPLATE_URL" \
  | jq \
      --arg name "$PROJECT_NAME" \
      --arg owner "$OWNER" \
      --arg number "$NUMBER" \
      --arg project_id "$PROJECT_ID" \
      --arg status_field_id "$STATUS_FIELD_ID" \
      --arg opt_planning "$OPT_PLANNING" \
      --arg opt_plan_refinement "$OPT_PLAN_REFINEMENT" \
      --arg opt_plan_review "$OPT_PLAN_REVIEW" \
      --arg opt_ready "$OPT_READY" \
      --arg opt_coding "$OPT_CODING" \
      --arg opt_code_review "$OPT_CODE_REVIEW" \
      --arg opt_done "$OPT_DONE" \
      '.project.name = $name
       | .project.owner = $owner
       | .project.number = $number
       | .project.id = $project_id
       | .status_field.id = $status_field_id
       | .status_field.options["In Planning"] = $opt_planning
       | .status_field.options["In Plan Refinement"] = $opt_plan_refinement
       | .status_field.options["In Plan Review"] = $opt_plan_review
       | .status_field.options["Ready"] = $opt_ready
       | .status_field.options["In Coding Progress"] = $opt_coding
       | .status_field.options["In Code Review"] = $opt_code_review
       | .status_field.options["Done"] = $opt_done' \
  > "$OUTPUT"

# Verify no placeholders remain
if grep -E '"<[A-Z_]+>"' "$OUTPUT" >/dev/null; then
  echo "WARN: unreplaced placeholders remain:" >&2
  grep -nE '"<[A-Z_]+>"' "$OUTPUT" >&2
  exit 1
fi

echo "ok: $OUTPUT"
