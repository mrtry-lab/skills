#!/usr/bin/env bash
# agile-project-setup Step 2.5: team-context.md 生成
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
#     [--output <path>]
#
# Default output: .claude/skills/references/team-context.md

set -euo pipefail

PRESET=""
TEAM_TYPE=""
MEMBERS=""
HOURS=""
REPO_TYPE="MONOREPO"
TASK_SPLIT="USE_CASE"
INFRA="INLINE"
TASK_UNIT_DESC=""
OUTPUT=".claude/skills/references/team-context.md"

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
    --output) OUTPUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# //;s/^#$//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

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
    PRESET_NAME="軽量"
    ;;
  standard)
    EPIC="5-7"; PERSONA="2-3"; VISION="60-90 分"; REFINE="30-60 分"
    RULE="7 個"; QUESTION="5 個"; TASK_COUNT="2 個"; CROSS_CUT="1 件以上"
    PRESET_NAME="標準"
    ;;
  focused)
    EPIC="10+"; PERSONA="3-5"; VISION="2-3 時間"; REFINE="60-90 分"
    RULE="10 個"; QUESTION="8 個"; TASK_COUNT="1 個"; CROSS_CUT="1 件以上"
    PRESET_NAME="集中"
    ;;
  *) echo "unknown preset: $PRESET (light|standard|focused)" >&2; exit 1 ;;
esac

mkdir -p "$(dirname "$OUTPUT")"

curl -fsSL https://raw.githubusercontent.com/mrtry-lab/skills/main/shared/references/team-context.md.template \
  -o "$OUTPUT"

# Detect GNU vs BSD sed
if sed --version >/dev/null 2>&1; then
  inplace() { sed -i "$@"; }
else
  inplace() { sed -i '' "$@"; }
fi

inplace \
  -e "s|<FULL_TIME / SIDE_PROJECT / MIXED>|$TEAM_TYPE|g" \
  -e "s|<軽量 / 標準 / 集中>|$PRESET_NAME|g" \
  -e "s|<N>|$MEMBERS|g" \
  -e "s|<HOURS>|$HOURS|g" \
  "$OUTPUT"

# Replace <VALUE> 8 times in order
inplace \
  -e "s|<VALUE>|$EPIC|" \
  -e "s|<VALUE>|$PERSONA|" \
  -e "s|<VALUE>|$VISION|" \
  -e "s|<VALUE>|$REFINE|" \
  -e "s|<VALUE>|$RULE|" \
  -e "s|<VALUE>|$QUESTION|" \
  -e "s|<VALUE>|$TASK_COUNT|" \
  -e "s|<VALUE>|$CROSS_CUT|" \
  "$OUTPUT"

inplace \
  -e "s|<MONOREPO / MULTI_REPO>|$REPO_TYPE|g" \
  -e "s|<USE_CASE / LAYER / COMPONENT / VERTICAL_SLICE / CUSTOM>|$TASK_SPLIT|g" \
  -e "s|<INLINE / SEPARATE_PR / N_A>|$INFRA|g" \
  -e "s|<例: 1 ユースケース分の BE+FE 統合 PR / BE か FE か Infra のいずれかのレイヤ 1 つ>|$TASK_UNIT_DESC|g" \
  "$OUTPUT"

if grep -nE '<[A-Z_]+( |>)' "$OUTPUT" >/dev/null; then
  echo "WARN: unreplaced placeholders may remain:"
  grep -nE '<[A-Z_]+( |>)' "$OUTPUT" || true
fi

echo "ok: $OUTPUT"
