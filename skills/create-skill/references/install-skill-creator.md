# skill-creator のインストール

`skill-creator` は Claude 公式の **プラグイン (skill ではない)** として配布されている。インストール方法は Claude Code のプラグイン管理機構に従う。

## インストール手順 (Claude Code)

### 1. プラグインマーケットプレイスの追加 (初回のみ)

Claude Code の CLI / IDE で:

```
/plugin marketplace add anthropics/skills
```

(or 同等の公式マーケットプレイス。詳細は下記公式ドキュメント参照)

### 2. skill-creator のインストール

```
/plugin install skill-creator
```

### 3. インストール確認

Claude Code の Skill tool 一覧に `skill-creator:skill-creator` が現れていれば完了。本スキル `create-skill` の `scripts/check-deps.sh --no-creator` を渡さずに実行して通れば OK。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| `/plugin` コマンドが存在しない | Claude Code のバージョンが古い可能性。`claude --version` で確認し、最新版にアップグレード |
| `skill-creator:skill-creator` が一覧に出てこない | Claude Code を再起動。プラグイン読込みはセッション開始時に行われる |
| マーケットプレイスの URL が分からない | 公式ドキュメント (下記) を参照。マーケットプレイス名は時期により変動する可能性 |

## 公式リファレンス

- Claude Code Plugins: <https://docs.claude.com/en/docs/claude-code/plugins>
- Claude Code 全般: <https://docs.claude.com/en/docs/claude-code>

## 代替: skill-creator なしで本スキルを使えるか?

不可。`create-skill` は Step 2 で skill-creator に初版生成を委譲する設計。skill-creator が無い環境では本スキルは動作しない。

どうしても skill-creator を入れられない場合は、手動で `skills/<name>/SKILL.md` を書き、Step 3 (skill-judge) 以降の評価 → 修正ループだけを本スキルから使う運用も一応可能 — その場合は Step 0 で「skill-creator なしで続行」を選び、Step 2 をスキップして Step 3 から開始する。
