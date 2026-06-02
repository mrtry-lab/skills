#!/usr/bin/env bash
#
# install-watcher.sh で常駐させた LaunchAgent を停止・削除する。

set -euo pipefail

LABEL="com.mrtry-lab.skills-sync"
PLIST_PATH="$HOME/Library/LaunchAgents/${LABEL}.plist"

if [ ! -f "$PLIST_PATH" ]; then
  echo "未インストール: $PLIST_PATH"
  exit 0
fi

launchctl unload "$PLIST_PATH" 2>/dev/null || true
rm -f "$PLIST_PATH"

echo "✓ removed: $PLIST_PATH"
