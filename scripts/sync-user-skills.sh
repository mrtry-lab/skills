#!/usr/bin/env bash
#
# repo の skills/* を ~/.claude/skills/ に symlink する。
#
# 用途: メンテナーがこの repo を直接編集する想定で、
# repo に新規 skill ディレクトリが増えたとき / 既存実体が壊れたときに再実行する。
# 既に symlink が正しく貼られている skill はスキップするので idempotent。
#
# Optional: git の post-merge hook に組み込めば、`git pull` 時に勝手に同期される。
#   git config core.hooksPath .githooks
#   .githooks/post-merge から本スクリプトを呼ぶ
#
# Exit code:
#   0 = OK
#   1 = git ls-files が動かない (repo の外?)

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude/skills"

if ! git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: $REPO は git repo ではない" >&2
  exit 1
fi

mkdir -p "$TARGET"

added=0
already=0
relinked=0

# git tracked な skills/<name>/ だけ対象 (workspace 等の .gitignore 済みは除外)
for s in $(git -C "$REPO" ls-files skills/ | awk -F/ '{print $2}' | sort -u); do
  src="$REPO/skills/$s"
  dst="$TARGET/$s"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    already=$((already + 1))
    continue
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "↻ relinked: $s"
    relinked=$((relinked + 1))
  else
    ln -s "$src" "$dst"
    echo "+ added:    $s"
    added=$((added + 1))
  fi
done

echo ""
echo "summary: added=$added relinked=$relinked already=$already"
