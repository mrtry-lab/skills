# 運用ガイド

## 用語マッピング

agile-* スキル群は **Scrum のフルセットを採用しているわけではなく、Agile / XP / BDD / Cynefin など複数の伝統から実用的な概念を組み合わせた構成**。そのため Scrum 公式用語とは表記が違うが概念的に対応する箇所がある。Scrum 経験者向けの対応表:

| 本スキル群の用語 | Scrum 公式 / 由来 | 補足 |
|---|---|---|
| Story (Issue Type) | Product Backlog Item (PBI) | ユーザー視点の機能単位。Story Mapping (Jeff Patton) / User Story (XP) の系譜で、Scrum の PBI に対応 |
| Story の集合 | Product Backlog | 本スキル群では「Story 群」「Story 一覧」と呼ぶ |
| Implementation Plan (Issue Type) | Sprint Backlog の "actionable plan for the Increment" | Scrum Expansion Pack v1.0 の表現を Issue Type 化したもの |
| Task (Issue Type) | Sprint Backlog の Task | 1 PR 単位の実装作業 |
| Epic (Issue Type) | (Scrum 標準にはない) | Agile/XP 由来、複数 Story にブレイクダウンされる大きな機能単位 |
| 受入基準 (Acceptance Criteria) | (Scrum Guide 自体にはない) | scrum.org 等の補助概念。本スキル群では Story の Yes/No 判定可能な条件として使用 |
| Outcome Done | Definition of Outcome Done | Scrum Guide Expansion Pack v1.0 由来。Output Done (実装完了) と Outcome Done (価値検証) を分離 |
| Three Amigos (PdO / Dev / QA) | (Scrum 標準にはない) | Agile/BDD 由来 (George Dinwiddie)。Refinement の網羅性検査に並列サブエージェントとして組み込み |
| Example Mapping | (Scrum 標準にはない) | BDD/Cucumber 由来 (Matt Wynne)。Story の受入基準を 4 色マップで抽出 |
| Cynefin の nature ラベル | Complexity 拡張章 | Scrum Guide Expansion Pack 経由 (元は Dave Snowden の経営理論) |
| Holistic Testing (Discover / Understand / Build / Deploy / **Observe**) | Holistic Testing 章 | Scrum Guide Expansion Pack 経由 (元は Lisa Crispin / Janet Gregory) |
| Plan mode | (Scrum 用語ではない) | Claude Code の機能。`agile-implement-task` で使用 |
| Backlog (View 名) | (Scrum 用語ではない) | 本スキル群で導入した GitHub Projects のビュー名。Open な Epic 配下を俯瞰する用途 |

Scrum 経験者は Story を PBI、Implementation Plan を Sprint Backlog の actionable plan、と読み替えればだいたい同じ。

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
     ├─ Implementation Plan          ← Dev リード視点: How の戦略 (Implementation Plan 必要パスのみ)
     └─ Task (1 PR 単位)             ← 実装者視点
```

Implementation Plan と Task はどちらも Story の **直下 sub-issue** として並列で並ぶ。Implementation Plan が Task の親ではない (時系列順では Implementation Plan Done → Task 起票)。

軽量パス (Implementation Plan 不要) の場合は Story の直下に Task が直接並ぶ。

### Task の粒度（1 PR 単位の定義）

「1 PR 単位」が何を意味するかはチームのリポジトリ構成と運用で異なる。`team-context.json` の「タスク分割単位」セクションに **機能実装の分割パターン** (`USE_CASE` / `LAYER` / `COMPONENT` / `VERTICAL_SLICE` / `CUSTOM`) と **基盤・インフラ系改修の扱い** (`INLINE` / `SEPARATE_PR` / `N_A`) を持ち、`agile-refine-implementation-plan` と `agile-decompose-task-from-implementation-plan` が参照する。設定方法は [setup.md](setup.md) 参照。

## GitHub Projects のビュー

チケットの状態は GitHub Projects (v2) で管理する。プロジェクトに Status フィールドを作成し、後述の 8 つのオプションを設定する。

運用上、Project のビューは **Backlog / Sprint / Overview の 3 つだけ** にする。Project 作成時にデフォルトで作られる `View 1` / `Table` 等は削除し、以下 3 つだけが残る状態を維持する:

- **Backlog** — Layout: **Board** / Group by: **Parent issue (Epic)** / Filter: `is:open status:"In Planning","In Plan Refinement","In Plan Review","Ready","In Coding Progress","Done" type:"Story"`
  Open な Epic 配下の Story を Epic 別に俯瞰するビュー。**表示されるのは Story だけ**で、Epic は Group by の親ヘッダーとして見える。**Story を持たない Epic はヘッダー自体が生成されず Backlog に出ない** ので、Story 分解が済んでいない Epic がノイズとして並ばない。Implementation Plan / Task は Sprint で追う。Epic が Done になると Sub-issue all closed → Parent auto-close で連鎖 close され、`is:open` フィルタで Backlog から自動的に外れる。

- **Sprint** — Layout: **Board** / Column by: **Status** / Swimlanes: **Parent issue (Story)** / Filter: `iteration:@current status:"Ready","In Coding Progress","In Code Review","Done" type:"Implementation Plan","Task"`
  **current iteration** の Implementation Plan / Task を Story 別に追うビュー。`iteration:@current` で current iteration スコープにすることで、PR merge で個別に close になった Done Task も current iteration の間は Sprint Done 列に残り続ける (達成感の見える化)。次 iteration に進めば前 iteration の subtree (shipped 済み Story 配下) は Sprint から自動で消える。Story 自身は Swimlanes の親ヘッダーとして見える。Iteration field を持たない Issue は `@current` にマッチしないので、Implementation Plan / Task は **起票時に必ず current iteration をセットする** 設計 (agile-create-issue Step 6)。

- **Overview** — Layout: **Table** / Group by: **Type** / Filter: (空 = 全件) / Show hierarchy: **On** / 表示フィールド: Title / Type / Status / Sub-issues progress
  全 Issue を Type 別に階層付きで俯瞰するビュー。Backlog / Sprint が「ある視点のスライス」なのに対し、Overview は **プロジェクトの全体像 (履歴含む)** を見るためのもの。`is:open` 等の絞り込みは付けず、closed や Done になった item も含めて全件見える状態にする。Epic → Story → Plan/Task の階層と各 Issue の完了率 (Sub-issues progress) が一覧できる。

Backlog / Sprint は構造が対称 (Epic→Story / Story→Plan,Task)。Overview はそれらの上位俯瞰として独立した役割。

プロジェクト固有値（Owner、Project ID、Status Field ID、Status Option ID、Iteration Field ID）は `shared/references/github-projects.json.template` を参考に `~/.claude/skills/references/github-projects.json`（または利用先プロジェクトの `.claude/skills/references/github-projects.json`）を作成する。

## Iteration field と Sprint スコープ

Sprint View は **Iteration field** で current iteration スコープを実現する。これにより:

- **PR merge で Task が close されても Sprint Done 列に残る** (Sprint Filter は close 状態ではなく iteration を見る)
- **Story が close されても、その配下の Plan/Task は current iteration の間は Sprint に残る**
- **次 iteration に進めば前 iteration の subtree は Sprint から自動で消える** (運用での「履歴送り」操作が不要)
- **Backlog / Overview は iteration スコープしない** ので、refinement pipeline 全体や全件俯瞰の役割を維持

### Iteration の期間と運用

duration は **180 日 (約半年) 固定**。preset 選択は行わない。

理由: 短期 (週次 / 隔週) duration だと GitHub Projects の date-based auto-advance によって `@current` が勝手に次 iteration に切り替わり、想定していない Story が Sprint Board から外れる事故が起きる。180 日固定 + future iteration を pre-create しない構成にすると、**ユーザー操作以外で Story が動かない設計** が成立する。

iteration を回すときに発生する作業:

1. **iteration 期間切れ (180 日後)** — `@current` が空になる (= Sprint Board 空)。次 iteration を回したくなったタイミングで手動作成
2. **carryover** — 前 iteration から取り残された Plan/Task を次 iteration に手動で移す (`set-issue-iteration.sh` で個別 issue を移す、または Web UI でドラッグ)
3. **新規 issue** — `/agile-create-issue` 経由で起票すれば `set-issue-iteration.sh` が呼ばれて current iteration に自動セット
4. **(任意) 履歴の整理** — 古い iteration option が field 設定に溜まる。気になるなら Web UI から削除 or rename

### Story の close との関係

Iteration スコープを採用したことで、**Story の close 状態は Sprint 表示には直接影響しない**。Story が closed になっても、その配下の Plan/Task が current iteration なら Sprint に残り続け、次 iteration に進むと一緒に消える。

代わりに、**Story の Done への遷移は `/agile-sprint-review` 経由で行う**。skill が OK 判定したら Story Status=Done + 子 Plan/Task の iteration クリアの両方をやって、Sprint Board からきれいに subtree を落とす。詳細は後述の「受け入れ確認フロー」を参照。

## Status フロー

Status フィールドには以下の 8 オプションを設定する:

```
In Planning → In Plan Refinement → In Plan Review → Ready → In Coding Progress
  → In Code Review → Awaiting sprint review → Done
```

| Status | Story での意味 | Implementation Plan での意味 | Task での意味 |
|--------|---------------|----------------------------|---------------|
| In Planning | Story Issue 作成直後 | (使わない) | (使わない) |
| In Plan Refinement | リファインメント中 (受入基準・Outcome を詳細化) | (使わない) | (使わない) |
| In Plan Review | リファインメント完了、PdO + QA レビュー中 | (使わない) | (使わない) |
| Ready | Refinement 完了。**Implementation Plan/Task 未作成** | Implementation Plan Issue 起票完了、Refinement 待ち | 仕様確定、実装着手可能 |
| In Coding Progress | **Implementation Plan or Task が作成済み (実装フェーズ入り)** | Implementation Plan 本文を編集中 (Refinement 継続) | CodingAgent が実装中 |
| In Code Review | (使わない) | Implementation Plan レビュー中 (Dev + PdO + QA) | PR レビュー中 |
| **Awaiting sprint review** | **子 Plan/Task が全 Done、受け入れ確認待ち** | (使わない) | (使わない) |
| Done | 受け入れ確認済み (`/agile-sprint-review` 経由) | Implementation Plan 承認完了 | PR マージ完了 |

**Implementation Plan Issue は Task と同じ 4 Status (`Ready` / `In Coding Progress` / `In Code Review` / `Done`) を使う**。これにより Sprint ビューに Implementation Plan も Story 配下で Task と並んで表示され、レビュー進捗を統一的に追える。Implementation Plan は PR を出さないが、`In Code Review` は「Implementation Plan ドキュメントのレビュー (Dev + PdO + QA)」を意味する。

`agile-refine-implementation-plan` Step 14 は **Refinement 完了済みの内容で Implementation Plan Issue を起票** するフローなので、起票時の Status は `In Code Review` (レビュー待ち) になる。再 Refinement が必要なら `In Coding Progress` に戻して編集 → `In Code Review` に戻す。

### Plan / Task 起票の前提条件 (Story Status Hard gate)

Implementation Plan / Task の起票は **親 Story が `Ready` 以降であることが前提**。`Ready` 未満 (`In Planning` / `In Plan Refinement` / `In Plan Review`) の Story から Plan / Task を起票すると、Sprint View に「親 Story 不在の Plan/Task」が並ぶ不整合が起きるため、起票スキル側で **Hard gate** を設けて拒否する設計:

- `agile-refine-implementation-plan` **Step 1** — Plan 起票前に親 Story Status を確認。`Ready` 未満なら中断、`/agile-refine-story` を案内
- `agile-decompose-task-from-implementation-plan` **Step 1** — 軽量モード (Story → Task 直接) で Hard gate。Plan ベースモードは Soft gate (警告のみ、Plan 存在自体が過去 Ready の証拠なので)
- `agile-create-issue` **Step 4** — 上流をバイパスされたときのセーフティネット

これにより Sprint には常に「`Ready` 以降の Story」と「その配下の Plan/Task」しか並ばない。

### Story の `Ready` → `In Coding Progress` 自動遷移

Hard gate を通過した起票では、Story は最初の Implementation Plan or Task が起票されたタイミングで `Ready` → `In Coding Progress` に遷移する。これにより Story 単体で「Refinement 完了済み・未着手」(Ready) と「実装フェーズ入り」(In Coding Progress) が判別できる。Backlog ビューでは Open Epic 配下の Story がライフサイクル全体にわたって見える。

遷移を発火するスキル:
- `agile-refine-implementation-plan` Step 15 後 — Implementation Plan Issue 起票完了時に親 Story が `Ready` なら遷移
- `agile-decompose-task-from-implementation-plan` Step 5 後 — 最初の Task Issue 起票完了時に親 Story が `Ready` なら遷移 (既に `In Coding Progress` ならスキップ)

既存 Story (新ルール導入前から `Ready` のまま実装が進んでいるもの) は遡及書き換えしない。新規 Story から新ルールを適用する。

### Story → Awaiting sprint review 遷移 (子全 Done の検知)

Hard gate を通過して実装が進み、Story 配下の Plan/Task が全 Done になったタイミングで、Story は `In Coding Progress` から **`Awaiting sprint review`** に乗る。これにより Backlog ビューに「受け入れ確認待ち」の Story が並び、ユーザーに review すべきものが見える状態になる。

**検知メカニズム**: `agile-sprint-review` 起動時の lazy scan で一括検出する。

- skill 内即時パス (Plan/Task Done と同時に親 Story を check) は持たない
- 理由: Status を Done に変える経路が複数あり (PR merge → Auto-close issue Workflow、手動 UI、`update-issue-status.sh`)、特に PR merge ルートは skill から検知できない。すべてのルートをフックすると複雑になるので、検知タイミングを `/agile-sprint-review` 起動時の 1 箇所に集約する設計
- `/agile-sprint-review` の Step 1 で `In Coding Progress` の Story を全件 scan し、`check-story-completion.sh <story-number>` を呼ぶ。子が全 Done だった Story は自動で `Awaiting sprint review` に遷移する

これにより「普段は何も起きない、レビューしようと skill を叩いた瞬間に揃う」設計が成立する。

### 受け入れ確認フロー (`/agile-sprint-review`)

`Awaiting sprint review` の Story を 1 件ずつ AC verify するスキル。

1. **取りこぼし回収 (lazy scan)**: 上記の通り `In Coding Progress` の Story を scan して `Awaiting sprint review` に促進
2. **候補列挙**: `Awaiting sprint review` の Story を全部 (過去 iteration から取り残されたものも拾える)
3. **各 Story を walkthrough**: AC / Outcome / 子 Plan/Task + linked PR を表示、ユーザーに OK / Reject / Skip を判定させる
4. **OK 処理**: Story Status=Done + 子 Plan/Task の iteration をクリア → Sprint Board から落ちる
5. **Reject 処理**: Story Status=In Coding Progress に戻す → 追加 Task 起票を案内
6. **Skip 処理**: 保留、次回再候補

詳細は `skills/agile-sprint-review/SKILL.md`。

### Done への遷移

Story の Done 条件:

1. 受入基準すべて満たす
2. Implementation Plan が Done (作成された場合のみ)
3. 全 Plan/Task が Done
4. `/agile-sprint-review` で OK 判定

Story → Done への遷移は **`/agile-sprint-review` 経由のみ** が正規ルート。手動で Status=Done に直接動かすこともできるが、本フローでは skill 経由を推奨 (子 iteration クリアまで一気に進む)。

## Implementation Plan 必要性判定

Story Refinement 後、Implementation Plan を作るか軽量パス (Story 直接 Task) かを判定する。基準は [concepts/implementation-plan.md](concepts/implementation-plan.md) 参照。

3 つのスキルから同じ基準を参照:

| スキル | 判定タイミング |
|--------|---------------|
| `agile-refine-story` Step 9 | Refinement の最後 (次スキル案内) |
| `agile-refine-implementation-plan` Step 2 | Implementation Plan スキル呼び出し直後 (副チェック) |
| `agile-decompose-task-from-implementation-plan` Step 1 | Task 起票スキル呼び出し時 (入力種別判定) |

判定基準は team-context.json preset で補正される (軽量は Implementation Plan 不要寄り、集中は Implementation Plan 必要寄り)。

## Three Amigos の責務分割

Story Refinement と Implementation Plan Refinement で Three Amigos の責務を分担する:

| 視点 | Story Refinement | Implementation Plan Refinement |
|------|------------------|----------------|
| **PdO** | 受入基準のビジネス妥当性、Outcome 整合 | Implementation Plan が Story の Outcome を逸脱していないかチェック |
| **Dev** | 概念レベルの実現可能性のみ | **メイン責務**: 実装戦略、API 設計、データモデル、テスト戦略 |
| **QA** | 受入基準のテスト可能性 | Implementation Plan のテスト戦略の網羅性 |

Story Refinement では PdO + QA メイン、Implementation Plan Refinement では Dev メイン (PdO + QA は補助レビュー)。

---

## トラブルシューティング

| 症状 | 原因 / 対処 |
|---|---|
| skill が `.claude/skills/references/github-projects.json` not found と言う | [setup.md](setup.md) の手順 2 を実施。プレースホルダ置換も忘れずに |
| ステータス更新コマンドが `<YOUR_GITHUB_ORG>` で失敗 | プレースホルダが未置換。手順 2 を再実行 |
| Mermaid バリデーションが失敗 | `validate-mermaid.mjs` の依存（jsdom / mermaid / dompurify）をインストールしたか確認 |
| Issue Type "Epic" / "Story" / "Implementation Plan" / "Task" が選択肢に出ない | Organization Settings → Planning → Issue types で 4 種類すべて登録 |
| 同梱テンプレートを使った後の登録確認が毎回出る | 仕様。No を選んだ場合は次回フォールバック使用時にも確認する。Yes でリポジトリに登録すれば、以降は自動でリポジトリ側のテンプレが使われる |
| Implementation Plan Issue が `In Planning` / `In Plan Refinement` / `In Plan Review` に遷移しそうになる | Implementation Plan は Task と同じ 4 Status (Ready / In Coding Progress / In Code Review / Done) を使う。`In Planning` / `In Plan Refinement` / `In Plan Review` は Story 専用 |
| 軽量 Story なのに Implementation Plan が作られた | `agile-refine-implementation-plan` Step 1 副チェックを使う。「不要では?」の問いに「不要」と答える |
| Story が `Ready` のまま Task 起票が進んでいる | Implementation Plan 起票 / 最初の Task 起票時の自動遷移が失敗している。`agile-refine-implementation-plan` Step 15 後 または `agile-decompose-task-from-implementation-plan` Step 5 後の Status 更新コマンドが正常終了したか確認、必要なら手動で In Coding Progress に更新 |
| Backlog ビューに Done Epic 配下の Story が残る | Sub-issue all closed → Parent auto-close を有効化していないと Epic が close されない。GitHub Projects の Workflows 設定を確認 |

---

## Contributing

### テンプレ重複の同期ルール

各 skill 配下の `templates/` には Issue / PR テンプレが同梱されている。`gh skill install` が skill 単位で動くため、各 skill が自己完結する設計を優先しており、複数 skill に同名テンプレが重複して存在する。

テンプレを更新する際は、以下の対応関係に注意して**両方を同期する**こと:

| Issue Type | 同梱先（複数） |
|---|---|
| Epic | `skills/agile-create-epic/templates/epic.md`, `skills/agile-create-issue/templates/epic.md` |
| Story | `skills/agile-create-stories/templates/story.md`, `skills/agile-create-issue/templates/story.md` |
| **Implementation Plan** | `skills/agile-create-issue/templates/implementation-plan.md` (起票時のみ参照されるので 1 箇所) |
| Task | `skills/agile-decompose-task-from-implementation-plan/templates/task.md`, `skills/agile-create-issue/templates/task.md` |
| PR | `skills/agile-create-pull-request/templates/pull_request_template.md` |

将来的に CI で diff チェックを入れる予定。
