# 運用ガイド

## Issue 分類体系

| カテゴリ | 分類方法 |
|---------|--------|
| 階層 | Issue Type: `Epic Issue`, `Story Issue`, **`Implementation Plan Issue`**, `Task Issue`（Organization 設定で管理） |
| 性質 | ラベル: `nature:implementable`, `nature:experimental`, `nature:chaotic` |
| 状態 | GitHub Projects の Status フィールド（下記参照） |

### Issue 階層

```
Epic
 └─ Story                            ← PdO/QA 視点: What/Why
     ├─ Implementation Plan          ← Dev リード視点: How の戦略 (Plan 必要パスのみ)
     └─ Task (1 PR 単位)             ← 実装者視点
```

Plan と Task はどちらも Story の **直下 sub-issue** として並列で並ぶ。Plan が Task の親ではない (時系列順では Plan Done → Task 起票)。

軽量パス (Plan 不要) の場合は Story の直下に Task が直接並ぶ。

## GitHub Projects のビュー

チケットの状態は GitHub Projects (v2) で管理する。プロジェクトに Status フィールドを作成し、後述の 7 つのオプションを設定する。

運用しやすくするため、用途別にビューを 2 つ用意することを推奨する:

- **仕様策定中のチケット** — `In Planning` / `In Plan Refinement` / `In Plan Review` でフィルタ。PdO + Dev リードが仕様 / 戦略を固めるフェーズ
- **コーディング待ちのチケット** — `Ready` / `In Coding Progress` / `In Code Review` でフィルタ。CodingAgent が実装するフェーズ

Issue Type 別の view を用意すると Plan と Task の見分けがつきやすい (Group by: Issue Type など)。

プロジェクト固有値（Owner、Project ID、Status Field ID、Status Option ID）は `shared/references/github-projects.md.template` を参考に `~/.claude/skills/references/github-projects.md`（または利用先プロジェクトの `.claude/skills/references/github-projects.md`）を作成する。

## Status フロー

既存の 7 オプションをそのまま流用。新規 Status は追加しない。

```
In Planning → In Plan Refinement → In Plan Review → Ready → In Coding Progress → In Code Review → Done
```

| Status | Story での意味 | Implementation Plan での意味 | Task での意味 |
|--------|---------------|----------------------------|---------------|
| In Planning | Story Issue 作成直後 | Plan Issue 作成直後 | (使わない) |
| In Plan Refinement | リファインメント中 (受入基準・Outcome を詳細化) | Plan Refinement 中 (技術詳細を詳細化) | (使わない) |
| In Plan Review | リファインメント完了、PdO + QA レビュー中 | Plan Refinement 完了、Dev リードレビュー中 | (使わない) |
| Ready | 仕様確定。Plan or Task 作成可能 | (使わない、Plan は In Plan Review → Done) | 仕様確定、実装着手可能 |
| In Coding Progress | (使わない、Story 全体の状態は Task で表す) | (使わない、Plan は PR を出さない) | CodingAgent が実装中 |
| In Code Review | (使わない) | (使わない) | PR レビュー中 |
| Done | 受入確認完了、全 Sub-issue Done | Plan レビュー完了 | PR マージ完了 |

**Plan Issue は `In Coding Progress` / `In Code Review` を使わない**。Plan は実装ドキュメントなので PR が出ない。In Plan Review が終わったら直接 Done に遷移。

### Done のカスケード

Story の Done 条件:

1. 受入基準すべて満たす
2. Plan が Done (作成された場合のみ)
3. 全 Task が Done
4. 受入確認完了

GitHub Projects 標準 Workflow「Sub-issue all closed → Parent auto-close」を有効化すれば半自動化できる。

## Plan 必要性判定

Story Refinement 後、Implementation Plan を作るか軽量パス (Story 直接 Task) かを判定する。基準は [concepts/implementation-plan.md](concepts/implementation-plan.md) 参照。

3 つのスキルから同じ基準を参照:

| スキル | 判定タイミング |
|--------|---------------|
| `agile-refine-backlog` Step 8 | Refinement の最後 (次スキル案内) |
| `agile-refine-implementation-plan` Step 1 | Plan スキル呼び出し直後 (副チェック) |
| `agile-implementation-plan-to-task` Step 1 | Task 起票スキル呼び出し時 (入力種別判定) |

判定基準は team-context.md preset で補正される (軽量は Plan 不要寄り、集中は Plan 必要寄り)。

## Three Amigos の責務分割

Story と Plan に分離した後、Three Amigos の責務も分かれる:

| 視点 | Story Refinement | Plan Refinement |
|------|------------------|----------------|
| **PdO** | 受入基準のビジネス妥当性、Outcome 整合 | Plan が Story の Outcome を逸脱していないかチェック |
| **Dev** | 概念レベルの実現可能性のみ | **メイン責務**: 実装戦略、API 設計、データモデル、テスト戦略 |
| **QA** | 受入基準のテスト可能性 | Plan のテスト戦略の網羅性 |

Story Refinement では PdO + QA メイン、Plan Refinement では Dev メイン (PdO + QA は補助レビュー)。

---

## トラブルシューティング

| 症状 | 原因 / 対処 |
|---|---|
| skill が `.claude/skills/references/github-projects.md` not found と言う | [setup.md](setup.md) の手順 2 を実施。プレースホルダ置換も忘れずに |
| ステータス更新コマンドが `<YOUR_GITHUB_ORG>` で失敗 | プレースホルダが未置換。手順 2 を再実行 |
| Mermaid バリデーションが失敗 | `validate-mermaid.mjs` の依存（jsdom / mermaid / dompurify）をインストールしたか確認 |
| Issue Type "Epic" / "Story" / "Implementation Plan" / "Task" が選択肢に出ない | Organization Settings → Planning → Issue types で 4 種類すべて登録 |
| 同梱テンプレートを使った後の登録確認が毎回出る | 仕様。No を選んだ場合は次回フォールバック使用時にも確認する。Yes でリポジトリに登録すれば、以降は自動でリポジトリ側のテンプレが使われる |
| Plan Issue が `In Coding Progress` に遷移しそうになる | Plan は PR を出さないので Coding 系を使わない。`In Plan Review → Done` で完結する。github-projects.md の Status 遷移ルールを確認 |
| 軽量 Story なのに Plan が作られた | `agile-refine-implementation-plan` Step 1 副チェックを使う。「不要では?」の問いに「不要」と答える |

---

## Contributing

### テンプレ重複の同期ルール

各 skill 配下の `templates/` には Issue / PR テンプレが同梱されている。`gh skill install` が skill 単位で動くため、各 skill が自己完結する設計を優先しており、複数 skill に同名テンプレが重複して存在する。

テンプレを更新する際は、以下の対応関係に注意して**両方を同期する**こと:

| Issue Type | 同梱先（複数） |
|---|---|
| Epic | `skills/agile-epic/templates/epic.md`, `skills/agile-create-issue/templates/epic.md` |
| Story | `skills/agile-create-backlog/templates/story.md`, `skills/agile-create-issue/templates/story.md` |
| **Implementation Plan** | `skills/agile-create-issue/templates/implementation-plan.md` (起票時のみ参照されるので 1 箇所) |
| Task | `skills/agile-implementation-plan-to-task/templates/task.md`, `skills/agile-create-issue/templates/task.md` |
| PR | `skills/agile-create-pull-request/templates/pull_request_template.md` |

将来的に CI で diff チェックを入れる予定。
