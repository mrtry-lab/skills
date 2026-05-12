#!/usr/bin/env bash
# agile-update-skills: agile-* スキル群と docs/agile-workflow/ + validate-mermaid.mjs を一括最新化
#
# Usage:
#   update.sh [--scope user|project] [--docs-dir <path>] [--scripts-dir <path>] \
#             [--skip-install] [--skip-docs] [--skip-scripts]
#
# Defaults:
#   --scope        user
#   --docs-dir     docs/agile-workflow
#   --scripts-dir  .claude/scripts

set -euo pipefail

REPO="mrtry-lab/skills"
SCOPE="user"
DOCS_DIR="docs/agile-workflow"
SCRIPTS_DIR=".claude/scripts"
SKIP_INSTALL=0
SKIP_DOCS=0
SKIP_SCRIPTS=0

SKILLS=(
  agile-product-vision
  agile-epic
  agile-create-stories
  agile-refine-story
  agile-refine-implementation-plan
  agile-implementation-plan-to-task
  agile-task-implementation
  agile-create-issue
  agile-create-pull-request
  agile-project-setup
  agile-update-skills
)

DOC_FILES_ROOT=(README.md setup.md operations.md)
DOC_FILES_CONCEPTS=(
  ai-decision-boundary.md
  cynefin.md
  example-mapping.md
  holistic-testing.md
  implementation-plan.md
  outcome-done.md
  quality-scoring.md
  strategy.md
  three-amigos.md
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2 ;;
    --docs-dir) DOCS_DIR="$2"; shift 2 ;;
    --scripts-dir) SCRIPTS_DIR="$2"; shift 2 ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    --skip-docs) SKIP_DOCS=1; shift ;;
    --skip-scripts) SKIP_SCRIPTS=1; shift ;;
    -h|--help)
      sed -n '2,11p' "$0" | sed 's/^# //;s/^#$//'
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ "$SCOPE" != "user" && "$SCOPE" != "project" ]]; then
  echo "ERROR: --scope must be 'user' or 'project' (got '$SCOPE')" >&2
  exit 1
fi

echo "=== agile-update-skills ==="
echo "scope:       $SCOPE"
echo "docs dir:    $DOCS_DIR"
echo "scripts dir: $SCRIPTS_DIR"
echo

# --- Step 1: skills ---
if [[ "$SKIP_INSTALL" == "1" ]]; then
  echo "[skip] gh skill install"
else
  echo "[1/3] installing ${#SKILLS[@]} skills via gh skill install --scope $SCOPE"
  failed=()
  for s in "${SKILLS[@]}"; do
    if gh skill install "$REPO" "$s" --agent claude-code --scope "$SCOPE"; then
      echo "  ok: $s"
    else
      echo "  FAIL: $s"
      failed+=("$s")
    fi
  done
  if [[ ${#failed[@]} -gt 0 ]]; then
    echo
    echo "WARN: failed to install: ${failed[*]}"
    echo "      retry manually with: gh skill install $REPO <name> --agent claude-code --scope $SCOPE"
  fi
fi

echo

# --- Step 2: docs ---
if [[ "$SKIP_DOCS" == "1" ]]; then
  echo "[skip] docs fetch"
else
  echo "[2/3] fetching docs into $DOCS_DIR/"
  mkdir -p "$DOCS_DIR/concepts"

  BASE="https://raw.githubusercontent.com/$REPO/main/docs/agile-workflow"

  for f in "${DOC_FILES_ROOT[@]}"; do
    curl -fsSL "$BASE/$f" -o "$DOCS_DIR/$f"
    echo "  ok: $DOCS_DIR/$f"
  done

  for f in "${DOC_FILES_CONCEPTS[@]}"; do
    curl -fsSL "$BASE/concepts/$f" -o "$DOCS_DIR/concepts/$f"
    echo "  ok: $DOCS_DIR/concepts/$f"
  done
fi

echo

# --- Step 3: shared scripts (validate-mermaid.mjs) ---
if [[ "$SKIP_SCRIPTS" == "1" ]]; then
  echo "[skip] scripts fetch"
else
  echo "[3/3] fetching shared scripts into $SCRIPTS_DIR/"
  mkdir -p "$SCRIPTS_DIR"

  SCRIPTS_BASE="https://raw.githubusercontent.com/$REPO/main/scripts"

  for f in validate-mermaid.mjs; do
    curl -fsSL "$SCRIPTS_BASE/$f" -o "$SCRIPTS_DIR/$f"
    echo "  ok: $SCRIPTS_DIR/$f"
  done
fi

echo
echo "=== done ==="
