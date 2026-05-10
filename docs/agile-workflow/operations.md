# 運用ガイド

## Issue 分類体系

| カテゴリ | 分類方法 |
|---------|--------|
| 階層 | Issue Type: `Epic Issue`, `Story Issue`, `Task Issue`（Organization 設定で管理） |
| 性質 | ラベル: `nature:implementable`, `nature:experimental`, `nature:chaotic` |
| 状態 | GitHub Projects の Status フィールド（下記参照） |

## GitHub Projects のビュー

チケットの状態は GitHub Projects (v2) で管理する。プロジェクトに Status フィールドを作成し、後述の 7 つのオプションを設定する。

運用しやすくするため、用途別にビューを 2 つ用意することを推奨する:

- **仕様策定中のチケット** — `In Planning` / `In Plan Refinement` / `In Plan Review` でフィルタ。PdO が仕様を固めるフェーズ
- **コーディング待ちのチケット** — `Ready` / `In Coding Progress` / `In Code Review` でフィルタ。CodingAgent が実装するフェーズ

プロジェクト固有値（Owner、Project ID、Status Field ID、Status Option ID）は `shared/references/github-projects.md.template` を参考に `~/.claude/skills/references/github-projects.md`（または利用先プロジェクトの `.claude/skills/references/github-projects.md`）を作成する。

## Status フロー

```
In Planning → In Plan Refinement → In Plan Review → Ready → In Coding Progress → In Code Review → Done
```

| Status | 意味 |
|--------|------|
| In Planning | Story Issue 作成直後。概要・粗い受入基準のみ |
| In Plan Refinement | リファインメント中。シーケンス図・画面仕様・受入基準を詳細化 |
| In Plan Review | リファインメント完了。PdO がレビュー中 |
| Ready | 仕様確定。Task Issue 分解・実装着手可能 |
| In Coding Progress | CodingAgent が実装中 |
| In Code Review | PR レビュー中 |
| Done | マージ完了 |

---

## トラブルシューティング

| 症状 | 原因 / 対処 |
|---|---|
| skill が `.claude/skills/references/github-projects.md` not found と言う | [setup.md](setup.md) の手順 2 を実施。プレースホルダ置換も忘れずに |
| ステータス更新コマンドが `<YOUR_GITHUB_ORG>` で失敗 | プレースホルダが未置換。手順 2 を再実行 |
| Mermaid バリデーションが失敗 | `validate-mermaid.mjs` の依存（jsdom / mermaid / dompurify）をインストールしたか確認 |
| Issue Type "Epic"（または Story / Task）が選択肢に出ない | Organization Settings → Planning → Issue types で登録 |
| 同梱テンプレートを使った後の登録確認が毎回出る | 仕様。No を選んだ場合は次回フォールバック使用時にも確認する。Yes でリポジトリに登録すれば、以降は自動でリポジトリ側のテンプレが使われる |

---

## Contributing

### テンプレ重複の同期ルール

各 skill 配下の `templates/` には Issue / PR テンプレが同梱されている。`gh skill install` が skill 単位で動くため、各 skill が自己完結する設計を優先しており、複数 skill に同名テンプレが重複して存在する。

テンプレを更新する際は、以下の対応関係に注意して**両方を同期する**こと:

| Issue Type | 同梱先（複数） |
|---|---|
| Epic | `skills/agile-epic/templates/epic.md`, `skills/agile-create-issue/templates/epic.md` |
| Story | `skills/agile-create-backlog/templates/story.md`, `skills/agile-create-issue/templates/story.md` |
| Task | `skills/agile-story-to-task/templates/task.md`, `skills/agile-create-issue/templates/task.md` |
| PR | `skills/agile-create-pull-request/templates/pull_request_template.md` |

将来的に CI で diff チェックを入れる予定。
