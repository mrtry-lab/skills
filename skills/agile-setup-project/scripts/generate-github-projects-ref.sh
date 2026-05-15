#!/usr/bin/env bash
# agile-setup-project Step 8: github-projects.json 生成
#
# 必須 env vars:
#   PROJECT_NAME            Project の表示名
#   OWNER                   GitHub Org / User
#   NUMBER                  Project Number
#   PROJECT_ID              Project ID (PVT_...)
#   STATUS_FIELD_ID         Status フィールド ID (PVTSSF_...)
#   OPT_PLANNING            In Planning option ID
#   OPT_PLAN_REFINEMENT     In Plan Refinement option ID
#   OPT_PLAN_REVIEW         In Plan Review option ID
#   OPT_READY               Ready option ID
#   OPT_CODING              In Coding Progress option ID
#   OPT_CODE_REVIEW         In Code Review option ID
#   OPT_AWAITING_REVIEW     Awaiting sprint review option ID
#   OPT_DONE                Done option ID
#   ITERATION_FIELD_ID      Iteration フィールド ID (PVTIF_...)
#   CURRENT_ITERATION_ID    現在の iteration ID (8 桁の hex)
#
# 任意:
#   APP_NAME          複数アプリ運用時のアプリ識別子 (例: "fieldnote")
#                     → 出力先が .claude/skills/references/github-projects.<APP_NAME>.json に切り替わる
#   OUTPUT            出力先パスを明示する (指定した場合 APP_NAME より優先)
#                     default: .claude/skills/references/github-projects.json

set -euo pipefail

if [[ -z "${OUTPUT:-}" ]]; then
  if [[ -n "${APP_NAME:-}" ]]; then
    OUTPUT=".claude/skills/references/github-projects.${APP_NAME}.json"
  else
    OUTPUT=".claude/skills/references/github-projects.json"
  fi
fi

required=(PROJECT_NAME OWNER NUMBER PROJECT_ID STATUS_FIELD_ID \
          OPT_PLANNING OPT_PLAN_REFINEMENT OPT_PLAN_REVIEW OPT_READY \
          OPT_CODING OPT_CODE_REVIEW OPT_AWAITING_REVIEW OPT_DONE \
          ITERATION_FIELD_ID CURRENT_ITERATION_ID)

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
      --arg opt_awaiting_review "$OPT_AWAITING_REVIEW" \
      --arg opt_done "$OPT_DONE" \
      --arg iter_field_id "$ITERATION_FIELD_ID" \
      --arg current_iter_id "$CURRENT_ITERATION_ID" \
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
       | .status_field.options["Awaiting sprint review"] = $opt_awaiting_review
       | .status_field.options["Done"] = $opt_done
       | .iteration_field.id = $iter_field_id
       | .iteration_field.current_iteration_id = $current_iter_id' \
  > "$OUTPUT"

# Verify no placeholders remain
if grep -E '"<[A-Z_]+>"' "$OUTPUT" >/dev/null; then
  echo "WARN: unreplaced placeholders remain:" >&2
  grep -nE '"<[A-Z_]+>"' "$OUTPUT" >&2
  exit 1
fi

echo "ok: $OUTPUT"
