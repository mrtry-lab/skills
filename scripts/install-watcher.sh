#!/usr/bin/env bash
#
# launchd LaunchAgent をインストールして、repo の skills/ ディレクトリの変更を
# 検知 → sync-user-skills.sh 自動実行する仕組みを常駐させる。
#
# 検知メカニズム: launchd の WatchPaths (FSEvents ベース)。
# 追加依存なし (fswatch 不要)。
#
# 起動時 + skills/ への変更時 (新規 dir / 削除 / リネーム / ファイル変更) に
# sync-user-skills.sh が走る。symlink 化されたファイル編集も WatchPaths を叩くが、
# sync は idempotent なので余分な実行は無害。
#
# ログ: /tmp/mrtry-skills-sync.{log,err}
# 停止: scripts/uninstall-watcher.sh

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
LABEL="com.mrtry-lab.skills-sync"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$PLIST_DIR/${LABEL}.plist"
SYNC_SCRIPT="$REPO/scripts/sync-user-skills.sh"

if [ ! -x "$SYNC_SCRIPT" ]; then
  echo "error: $SYNC_SCRIPT が実行可能じゃない" >&2
  exit 1
fi

mkdir -p "$PLIST_DIR"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${SYNC_SCRIPT}</string>
  </array>

  <key>WatchPaths</key>
  <array>
    <string>${REPO}/skills</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>ThrottleInterval</key>
  <integer>2</integer>

  <key>StandardOutPath</key>
  <string>/tmp/mrtry-skills-sync.log</string>

  <key>StandardErrorPath</key>
  <string>/tmp/mrtry-skills-sync.err</string>
</dict>
</plist>
EOF

# 既に load 済みなら unload してから再 load (plist 内容変更を反映)
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "✓ installed: $PLIST_PATH"
echo "  WatchPaths: $REPO/skills"
echo "  log:        /tmp/mrtry-skills-sync.log"
echo "  err:        /tmp/mrtry-skills-sync.err"
echo ""
echo "確認: launchctl list | grep ${LABEL}"
echo "停止: bash scripts/uninstall-watcher.sh"
