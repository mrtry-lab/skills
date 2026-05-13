#!/usr/bin/env bash
# agile-setup-project Step 2.5: team-context.json 生成
#
# Usage:
#   generate-team-context.sh \
#     --preset <light|standard|focused> \
#     --type <FULL_TIME|SIDE_PROJECT|MIXED> \
#     --members <N> --hours <N> \
#     --repo-type <MONOREPO|MULTI_REPO> \
#     --task-split <USE_CASE|LAYER|COMPONENT|VERTICAL_SLICE|CUSTOM> \
#     --infra <INLINE|SEPARATE_PR|N_A> \
#     --task-unit-desc <text> \
#     [--timezone <text>] [--location <text>] [--skill-bias <text>] [--notes <text>] \
#     [--app <app-name>] [--output <path>]
#
# Default output:
#   .claude/skills/references/team-context.json
#   .claude/skills/references/team-context.<app>.json  (--app 指定時)

set -euo pipefail

PRESET=""
TEAM_TYPE=""
MEMBERS=""
HOURS=""
REPO_TYPE="MONOREPO"
TASK_SPLIT="USE_CASE"
INFRA="INLINE"
TASK_UNIT_DESC=""
TIMEZONE=""
LOCATION=""
SKILL_BIAS=""
NOTES=""
APP_NAME=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preset) PRESET="$2"; shift 2 ;;
    --type) TEAM_TYPE="$2"; shift 2 ;;
    --members) MEMBERS="$2"; shift 2 ;;
    --hours) HOURS="$2"; shift 2 ;;
    --repo-type) REPO_TYPE="$2"; shift 2 ;;
    --task-split) TASK_SPLIT="$2"; shift 2 ;;
    --infra) INFRA="$2"; shift 2 ;;
    --task-unit-desc) TASK_UNIT_DESC="$2"; shift 2 ;;
    --timezone) TIMEZONE="$2"; shift 2 ;;
    --location) LOCATION="$2"; shift 2 ;;
    --skill-bias) SKILL_BIAS="$2"; shift 2 ;;
    --notes) NOTES="$2"; shift 2 ;;
    --app) APP_NAME="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Resolve OUTPUT path. --output > --app-derived > single-app default.
if [[ -z "$OUTPUT" ]]; then
  if [[ -n "$APP_NAME" ]]; then
    OUTPUT=".claude/skills/references/team-context.${APP_NAME}.json"
  else
    OUTPUT=".claude/skills/references/team-context.json"
  fi
fi

for var in PRESET TEAM_TYPE MEMBERS HOURS TASK_UNIT_DESC; do
  if [[ -z "${!var}" ]]; then
    echo "ERROR: --${var,,} is required" >&2
    exit 1
  fi
done

case "$PRESET" in
  light)
    EPIC="2-3"; PERSONA="1-2"; VISION="30-60 分"; REFINE="25-30 分"
    RULE="5 個"; QUESTION="3 個"; TASK_COUNT="3 個"; CROSS_CUT="2 件以上"
    ;;
  standard)
    EPIC="5-7"; PERSONA="2-3"; VISION="60-90 分"; REFINE="30-60 分"
    RULE="7 個"; QUESTION="5 個"; TASK_COUNT="2 個"; CROSS_CUT="1 件以上"
    ;;
  focused)
    EPIC="10+"; PERSONA="3-5"; VISION="2-3 時間"; REFINE="60-90 分"
    RULE="10 個"; QUESTION="8 個"; TASK_COUNT="1 個"; CROSS_CUT="1 件以上"
    ;;
  *) echo "unknown preset: $PRESET (light|standard|focused)" >&2; exit 1 ;;
esac

mkdir -p "$(dirname "$OUTPUT")"

TEMPLATE_URL="https://raw.githubusercontent.com/mrtry-lab/skills/main/shared/references/team-context.json.template"

# Fetch template + apply values in one jq pipeline
curl -fsSL "$TEMPLATE_URL" \
  | jq \
      --arg type "$TEAM_TYPE" \
      --argjson members "$MEMBERS" \
      --argjson hours "$HOURS" \
      --arg preset "$PRESET" \
      --arg epic "$EPIC" \
      --arg persona "$PERSONA" \
      --arg vision "$VISION" \
      --arg refine "$REFINE" \
      --arg rule "$RULE" \
      --arg question "$QUESTION" \
      --arg task_count "$TASK_COUNT" \
      --arg cross_cut "$CROSS_CUT" \
      --arg repo_type "$REPO_TYPE" \
      --arg task_split "$TASK_SPLIT" \
      --arg infra "$INFRA" \
      --arg task_unit_desc "$TASK_UNIT_DESC" \
      --arg timezone "$TIMEZONE" \
      --arg location "$LOCATION" \
      --arg skill_bias "$SKILL_BIAS" \
      --arg notes "$NOTES" \
      '.team.type = $type
       | .team.members = $members
       | .team.weekly_hours = $hours
       | .team.preset = $preset
       | .thresholds.max_active_epics = $epic
       | .thresholds.active_personas = $persona
       | .thresholds.vision_session_minutes = $vision
       | .thresholds.refinement_session_minutes = $refine
       | .thresholds.example_mapping_rule_limit = $rule
       | .thresholds.unresolved_question_limit = $question
       | .thresholds.plan_path_task_count_threshold = $task_count
       | .thresholds.plan_path_cross_cutting_threshold = $cross_cut
       | .task_split.repo_type = $repo_type
       | .task_split.pattern = $task_split
       | .task_split.infra_handling = $infra
       | .task_split.task_unit_description = $task_unit_desc
       | .team_specifics.timezone = $timezone
       | .team_specifics.location = $location
       | .team_specifics.skill_bias = $skill_bias
       | .team_specifics.notes = $notes' \
  > "$OUTPUT"

# Verify no unfilled placeholders remain
if grep -E '"<[A-Za-z _/]+>"' "$OUTPUT" >/dev/null; then
  echo "WARN: unreplaced placeholders may remain:" >&2
  grep -nE '"<[A-Za-z _/]+>"' "$OUTPUT" >&2
fi

echo "ok: $OUTPUT"
