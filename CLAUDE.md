# CLAUDE.md

このリポジトリは **Claude Code 用の skill 集**。ここで作成・編集される skill はすべて Claude Code (CLI / IDE / Web) 上で実行されることを前提とする。新規 skill を作るとき、既存 skill を改修するときは、本ファイルの方針に従うこと。

---

## 大前提: Claude Code が提供するツールを活用する

skill の中の指示は、最終的に Claude Code の harness 上で実行される。harness は単なる「テキスト LLM」ではなく、複数の構造化ツール (AskUserQuestion / TaskCreate / ExitPlanMode / Read / Grep / Bash 等) を提供している。**「テキスト出力で対話する」だけで完結させず、適切なツールを組み合わせる** ことが UX 向上の鍵。

skill を書くときは、テキスト指示で済ますのではなく、対応する Claude Code ツールがないか必ず検討する。

### よく使うべきツールと使いどころ

| ツール | 使いどころ | 詳細 |
|---|---|---|
| **`AskUserQuestion`** | 選択肢が 2-4 個の有限な質問 | preset / mode / yes-no / 承認可否。`Other` は自動付与されるので「自由記述に逃げる保険」もある。`(Recommended)` を先頭オプションに付けると推奨が示せる |
| **`TaskCreate` / `TaskUpdate` / `TaskList`** | 5 ステップ以上ある skill の進捗管理 | Workflow の各 Step を Task として起こし、`in_progress` / `completed` を遷移させる。並列サブエージェントもレーンとして見える。途中中断 → 再開時の文脈復元が楽 |
| **`ExitPlanMode`** | Issue 起票 / PR 作成 / Project Status 変更 / Workflow 設定変更など、**外部状態を変える操作の直前** | Plan mode に入って計画を提示し、`ExitPlanMode` でユーザー承認を取る。読み取り系・対話系のゲートは普通のテキスト確認でよい |
| **`Read`** | リポジトリ内の既存実装・テンプレ・参考資料を読む | PDF / Notebook 対応もしている |
| **`Grep` / Bash `grep`** | ファイル横断検索 | Pattern + glob で素早く絞り込める |
| **`Bash`** | 同梱 `scripts/*.sh` の実行、`gh` / `jq` などの CLI 呼び出し | sed/jq の長いワンライナーは SKILL.md に書かず `scripts/` に切り出す |
| **`WebFetch`** | 外部の公式ドキュメント・ガイドを取得 | 引用元のリンクを残す前提で |
| **`Agent`** | サブエージェント並列起動 (Three Amigos 等) | 視点が独立する検査・レビューで真価を発揮 |

### 自由記述が要る箇所はテキスト対話を維持

ユーザーストーリーの文章、ミッション文、Outcome 仮説、API 仕様の詳細など、**4 択に押し込むと質が落ちる** ものは普通のテキスト対話で書いてもらう。AskUserQuestion を万能ツールとして使わない。

---

## Skill 作成時のチェックリスト

新規 skill を作成 / 既存 skill を改修するとき、以下を確認:

- [ ] **冒頭ポインタ 3 行を入れる** — AskUserQuestion / TaskCreate / ExitPlanMode の利用方針 (`agile-*` SKILL.md 群を参照、文言は揃える)
- [ ] **多段階 (5+ Step) なら Workflow 図を mermaid で書く** — `flowchart TB` で Step 名 + 矢印
- [ ] **人間承認ゲート** を SKILL.md 末尾の「決定境界」セクションに列挙する。Issue/PR/Status 系は Plan mode に乗せる
- [ ] **不可逆操作の前に `ExitPlanMode` を呼ぶ** ように Step 説明で明示する
- [ ] **NEVER アンチパターン** を末尾に列挙 (やってはいけない操作を具体化)
- [ ] **References** セクションに参考にした書籍 / 記事 / フレームワークを列挙
- [ ] **長い処理は `scripts/*.sh` に切り出す** — SKILL.md にインライン bash の長文を書き戻さない
- [ ] **テンプレートは `templates/`、参考資料は `references/` に分離** する

---

## ディレクトリ構成

```
skills/<skill-name>/
├── SKILL.md              # スキル本体 (frontmatter + 本文)
├── scripts/              # 実行可能スクリプト (任意)
├── templates/            # 同梱テンプレ (任意、Issue / PR 用 等)
└── references/           # 参考資料 (任意、テンプレ的文書 等)

docs/
├── agile-workflow/       # agile-* 共通の運用概念ドキュメント
│   ├── README.md         # ワークフロー全体像 + skill 一覧
│   ├── setup.md          # セットアップ手順
│   ├── operations.md     # Status フロー / ビュー / 用語マッピング 等
│   └── concepts/         # 概念定義 (Cynefin / Three Amigos / Outcome Done 等)
└── vision/               # プロダクトビジョン (利用者リポジトリでは README.md + 任意の参考資料)

shared/
└── references/           # 全 skill が参照する設定テンプレ (JSON)
    ├── github-projects.json.template
    └── team-context.json.template
```

`docs/agile-workflow/concepts/` は **agile 運用そのものの概念** だけを置く。Claude Code 固有の指示 (AskUserQuestion の使い方等) はこのディレクトリには入れない (本ファイル CLAUDE.md か skills/<name>/SKILL.md に書く)。

---

## 命名規約

- **Skill 名**: `[動詞]-[名詞]` 形式 (例: `agile-create-stories`, `agile-refine-story`, `agile-decompose-task-from-implementation-plan`)
- **設定ファイル**: JSON (`.json.template`)。markdown はデータ保存に使わない (jq で構造化アクセスするため)
- **ファイル内日付フィールド** (`最終更新: {YYYY-MM-DD}` 等) は書かない — git の履歴で十分

---

## agile-* スキル群について

agile 運用ワークフロー専用の 11 個の skill が `skills/agile-*` に配置されている。ワークフロー全体像・運用ガイド・前提条件は **[docs/agile-workflow/](docs/agile-workflow/)** を参照。

利用者の典型的な導入手順:
1. `gh skill install mrtry-lab/skills agile-setup-project --agent claude-code --scope user`
2. `/agile-setup-project` を実行 (内部で `/agile-update-skills` に委譲して残り 10 個と docs/agile-workflow/ を fetch)

---

## 関連ドキュメント

- `docs/agile-workflow/README.md` — agile-* 全体像
- `docs/agile-workflow/operations.md` — Status フロー / 用語マッピング
- `docs/agile-workflow/concepts/` — 各種概念の深掘り (Cynefin / Three Amigos / Outcome Done / Strategy 等)
- `skills/agile-update-skills/SKILL.md` — skill 群と docs の一括更新フロー
