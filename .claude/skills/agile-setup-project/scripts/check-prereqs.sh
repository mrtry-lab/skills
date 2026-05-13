#!/usr/bin/env bash
# agile-setup-project Step 1: 前提チェック
#
# Usage: check-prereqs.sh
#
# Exit codes:
#   0  OK
#   1  auth missing
#   2  project scope missing

set -euo pipefail

echo "[1/2] gh auth status"
if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh not authenticated. Run: gh auth login" >&2
  exit 1
fi
gh auth status

echo
echo "[2/2] verifying 'project' scope"
if gh auth status 2>&1 | grep -q "'project'"; then
  echo "ok: project scope present"
else
  echo "ERROR: 'project' scope missing. Run: gh auth refresh -s project,read:org" >&2
  exit 2
fi
