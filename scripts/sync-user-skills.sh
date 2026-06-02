#!/usr/bin/env bash
#
# repo の skills/<name>/SKILL.md を持つディレクトリを ~/.claude/skills/ に symlink する。
#
# 判定基準: <repo>/skills/<name>/SKILL.md が直下に存在するか。
# git tracked かどうかは見ない (未コミットの新規 skill も検出するため)。
# workspace 系 (iteration-N/ などにしか SKILL.md がない) は自動除外される。
#
# 動作:
#   1) 既に正しい symlink → スキップ
#   2) 別物が居る (実体ディレクトリ / 別の symlink) → 削除して再 link
#   3) ~/.claude/skills/ にある repo を指している symlink で、もう repo 側に該当が無いもの → 削除
#
# Exit code:
#   0 = OK
#   1 = repo path 解決失敗

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude/skills"

if [ ! -d "$REPO/skills" ]; then
  echo "error: $REPO/skills が無い" >&2
  exit 1
fi

mkdir -p "$TARGET"

# 現在 repo に存在する skill (直下 SKILL.md を持つディレクトリ)
declare -a current=()
for sd in "$REPO"/skills/*/; do
  name=$(basename "$sd")
  [ -f "$sd/SKILL.md" ] || continue
  current+=("$name")
done

added=0
already=0
relinked=0
removed=0

# 1) stale symlink の除去
for dst in "$TARGET"/*; do
  [ -L "$dst" ] || continue
  link_target=$(readlink "$dst")
  case "$link_target" in
    "$REPO/skills/"*)
      name=$(basename "$dst")
      found=0
      for s in "${current[@]:-}"; do
        if [ "$s" = "$name" ]; then found=1; break; fi
      done
      if [ "$found" -eq 0 ]; then
        rm "$dst"
        echo "- removed:  $name (repo に SKILL.md が無くなった)"
        removed=$((removed + 1))
      fi
      ;;
  esac
done

# 2) 必要な symlink を作成 / 修正
for name in "${current[@]:-}"; do
  src="$REPO/skills/$name"
  dst="$TARGET/$name"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    already=$((already + 1))
    continue
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "↻ relinked: $name"
    relinked=$((relinked + 1))
  else
    ln -s "$src" "$dst"
    echo "+ added:    $name"
    added=$((added + 1))
  fi
done

echo ""
echo "summary: added=$added relinked=$relinked removed=$removed already=$already"
