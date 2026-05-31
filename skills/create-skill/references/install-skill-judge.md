# skill-judge のインストール

`skill-judge` は **Agent Skill (プラグインではない)** として `softaworks/agent-toolkit` リポジトリで配布されている。GitHub CLI の `gh skill` サブコマンド経由でインストールする。

## 前提

- `gh` (GitHub CLI) がインストール済み
- `gh skill` サブコマンド (preview 機能) が利用可能 — `gh skill --help` で確認

## インストール手順

### user scope (推奨: 全プロジェクトで使い回せる)

```bash
gh skill install softaworks/agent-toolkit skill-judge --agent claude-code --scope user
```

設置先: `~/.claude/skills/skill-judge/`

### project scope (このリポジトリ内でだけ使う)

```bash
gh skill install softaworks/agent-toolkit skill-judge --agent claude-code --scope project
```

設置先: `<repo>/.claude/skills/skill-judge/`

### scope の使い分け

| scope | こんなときに |
|---|---|
| user | 複数プロジェクトで `create-skill` を使う / 自分専用の skill 開発環境を整えたい |
| project | チーム共有リポジトリで全員に skill-judge を強制したい / `.claude/` を git 管理している |

## インストール確認

```bash
ls -la ~/.claude/skills/skill-judge/SKILL.md          # user scope
ls -la .claude/skills/skill-judge/SKILL.md            # project scope
```

どちらかが存在すれば本スキル `create-skill` の `scripts/check-deps.sh` が `skill-judge: OK` を返す。

## 内容の事前確認 (preview)

実際にインストールする前に中身を見たい場合:

```bash
gh skill preview softaworks/agent-toolkit skill-judge
```

SKILL.md + README.md がプレーンテキストで出力される。

## ミラー / 派生版について

`skill-judge` は人気スキルで、複数のテンプレ集リポジトリにミラーされている (`davila7/claude-code-templates` 等)。内容はバイト単位で一致しているが、**インストールパスが異なる / `gh skill install` で素直に取れない** ことがあるため、本スキルでは canonical な `softaworks/agent-toolkit` を推奨する。

## 公式リファレンス

- 本家リポジトリ: <https://github.com/softaworks/agent-toolkit>
- skill-judge SKILL.md: <https://github.com/softaworks/agent-toolkit/blob/main/skills/skill-judge/SKILL.md>
- Agent Skills 仕様: <https://agentskills.io/specification>

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `gh skill: unknown command` | `gh` を最新版へ。`gh skill` は preview 機能 (`gh extension install` ではない) |
| `Permission denied` 系で auto mode に止められる | `! gh skill install ...` 形式でユーザー手元で実行してもらう |
| インストール後も skill-judge が呼び出せない | Claude Code を再起動。skill 読込みはセッション開始時 |
