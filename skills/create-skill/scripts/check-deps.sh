#!/usr/bin/env bash
# create-skill 依存検出スクリプト
#
# 使い方:
#   bash scripts/check-deps.sh                   # 両方検出
#   bash scripts/check-deps.sh --no-creator      # skill-creator は呼び出し側で確認済み、judge だけ検査
#   bash scripts/check-deps.sh --no-judge        # 逆
#
# 終了コード:
#   0 = すべての必要な依存が見つかった
#   1 = 不足あり (stderr に内訳)
#   2 = スクリプト引数エラー

set -euo pipefail

CHECK_CREATOR=1
CHECK_JUDGE=1

for arg in "$@"; do
  case "$arg" in
    --no-creator) CHECK_CREATOR=0 ;;
    --no-judge)   CHECK_JUDGE=0 ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

missing=0

# ----- skill-creator -----
# skill-creator は Claude プラグイン。シェルから直接検出はできないため、
# このスクリプトでは「user の指示を表示するだけ」に留める。
# 呼び出し側 (Claude) が Skill tool 一覧で skill-creator:skill-creator を確認した後、
# OK なら --no-creator を渡してこのスクリプトを再実行する運用。
if [ "$CHECK_CREATOR" -eq 1 ]; then
  echo "skill-creator: ⚠️  シェルからは検出不可"
  echo "  → Claude の Skill tool 一覧に 'skill-creator:skill-creator' があるか目視確認してください"
  echo "  → ある場合はこのスクリプトに --no-creator を渡して再実行"
  echo "  → 無い場合は references/install-skill-creator.md の手順でインストール"
  echo ""
fi

# ----- skill-judge -----
if [ "$CHECK_JUDGE" -eq 1 ]; then
  judge_user="${HOME}/.claude/skills/skill-judge/SKILL.md"
  judge_project=".claude/skills/skill-judge/SKILL.md"

  if [ -f "$judge_user" ]; then
    echo "skill-judge: ✅ user scope ($judge_user)"
  elif [ -f "$judge_project" ]; then
    echo "skill-judge: ✅ project scope ($judge_project)"
  else
    echo "skill-judge: ❌ 未インストール" >&2
    echo "  → 推奨: gh skill install softaworks/agent-toolkit skill-judge --agent claude-code --scope user" >&2
    echo "  → 詳細: references/install-skill-judge.md" >&2
    missing=$((missing + 1))
  fi
fi

if [ "$missing" -gt 0 ]; then
  echo "" >&2
  echo "不足: ${missing} 件。create-skill の Step 0 で対応してから Step 1 に進んでください。" >&2
  exit 1
fi

exit 0
