# Agile 開発ワークフローガイド

`agile-*` スキル群を使ったプロダクト開発ワークフロー。アジャイル / XP の知見を取り入れつつ、小規模・副業チームでも運用できる軽量な構成にしている。

## 全体像

```mermaid
flowchart TB
  subgraph vision["① ビジョン策定"]
    v1["/agile-product-vision"]
    v2["docs/VISION.md"]
    v1 --> v2
  end

  subgraph epicdef["② Epic Issue 定義"]
    e1["/agile-epic"]
    e2["Epic Issue を作成"]
    e1 --> e2
  end

  subgraph planning["③ バックログ作成 — Status: In Planning"]
    b1["/agile-create-backlog"]
    b2["Story Issue を作成"]
    b1 --> b2
  end

  subgraph refinement["④ リファインメント — Status: In Plan Refinement"]
    r1["/agile-refine-backlog\nStory Issue を詳細化"]
  end

  review["⑤ プランレビュー\nStatus: In Plan Review"]

  branch{"nature?"}

  subgraph taskphase["⑥ タスク分解 — Status: Ready"]
    t1["/agile-story-to-task"]
    t2["Task Issue を作成"]
    t1 --> t2
  end

  subgraph coding["⑦ 実装 — Status: In Coding Progress → In Code Review → Done"]
    c1["/agile-task-implementation\nPlan → TDD → Draft PR"]
    c2["PR レビュー → マージ"]
    c1 --> c2
  end

  spike["⑥' スパイク実施\n(人間が実験)"]
  newstory["/agile-create-backlog\n新たな Story Issue を作成"]
  pivot["ピボット or 破棄"]

  v2 --> e1
  e2 --> b1
  b2 --> r1
  r1 -- "検査通過" --> review --> branch
  branch -- "implementable" --> t1
  t2 --> c1
  branch -- "experimental" --> spike
  spike -- "成功" --> newstory
  spike -- "失敗" --> pivot
  newstory --> b1
```

## 開発スタイル

- アジャイル / XP の知見を活用するが、スクラムのフレームワークには縛られない
- 定例で「次にどの Story Issue をやるか」を決める程度の軽い計画
- 実装は CodingAgent が主体。Task Issue 単位で実装し、PR 単位で成果物が出る
- Issue 階層は **Epic Issue → Story Issue → Task Issue の 3 層**。リファインメント済み Story Issue を `/agile-story-to-task` で Task Issue に分解し、CodingAgent に渡す

## 6 つのスキル

### 1. `/agile-product-vision` — ビジョン策定

チームの前提認知を揃えるための `docs/VISION.md` を対話的に作成・更新する。

**5 層構造**:
1. **Why**: ミッション、エレベーターピッチ、ビジョンステートメント
2. **Who**: ターゲットユーザー / ペルソナ、ステークホルダーマップ
3. **What**: ユーザーの課題と現在の解決策、Not-to-do リスト、成功指標
4. **How**: ソリューション概要、トレードオフスライダー
5. **When/Risk**: タイムライン見通し、リスクリスト、リソース見積もり

**更新頻度**: 四半期〜半年単位。状況変化で前提が崩れたら見直す。

### 2. `/agile-epic` — Epic Issue 定義

Opportunity Canvas を用いて Epic Issue を作成・更新する。

**2 つのモード**:
- **0→1**: VISION.md から Epic Issue 候補を導出
- **1→N**: 新しいトリガー（ユーザーの声、データ等）から Epic Issue を追加

**Opportunity Canvas の構造**:
- 左側 = **Problem Space（事実）**: ユーザーの課題、ターゲットユーザー、現在の解決策、ビジネス上の課題
- 右側 = **Solution Space（仮説）**: ユーザーの価値ストーリー、成功指標、導入戦略、ビジネスインパクト、予算感

**4 リスクチェック**: 価値 / ユーザビリティ / 実現可能性 / 事業継続性

**注意**: 小規模チームでアクティブな Epic Issue は 2-3 個が限界。

### 3. `/agile-create-backlog` — バックログ作成

Epic Issue を Story Mapping で分解し、Cynefin ドメイン分類で仕分けて Story Issue を作成する。

**6 ステップ**:
1. Epic Issue 読み込み
2. ストーリーマップ作成（横 = 活動の流れ、縦 = 詳細度）
3. 探索（サブタスク・例外・代替パスを発散的に洗い出す）
4. **Cynefin ドメイン分類**（このステップがパイプライン全体の分岐点）
5. リリーススライス（Opening Game → Mid Game → End Game）
6. Story Issue 登録

**Cynefin ドメイン分類**:

| 判断基準 | 分類 | ラベル |
|---------|------|--------|
| 受入基準を今すぐ書ける / 調べればわかる | implementable | `nature:implementable` |
| やってみないとわからない | experimental | `nature:experimental` |

- experimental のタイトルは「〇〇について実験する」形式にする
- 全部 implementable は危険信号。未検証の前提の上に実装を積み上げている可能性がある

### 4. `/agile-refine-backlog` — リファインメント

Story Issue の要件を、CodingAgent が Issue 本文だけ読んで実装を開始できるレベルまで具体化する。シーケンス図でアクター間の相互作用と正常系 / 異常系パターンを洗い出し、画面仕様・API 仕様・受入基準を確定させる。implementable も experimental も **同じフロー** でリファインメントし、分岐するのはリファインメント完了後の行き先だけ。

**原則**: 1 Story Issue = 1 つのユーザー価値。複数の価値が混在していたら分割する。

**リファインメントの流れ（共通）**:
1. ビジョン整合レビュー（サブエージェント）
2. シーケンス図作成（アクター・システム間の相互作用 + alt/opt で正常系 / 異常系パターンを統合表現）
3. 画面仕様・API 仕様・イベントロギング
4. 受入基準生成
5. 網羅性検査（サブエージェント）
6. リファインメント完了（GitHub Projects の Status フィールドを次の状態に更新）

**リファインメント完了後の分岐**:
- `nature:implementable` → `/agile-story-to-task` で Task Issue 分解 → CodingAgent へ
- `nature:experimental` → 人間がスパイクを実施 → 成功なら `/agile-create-backlog` で新 Story Issue 作成 / 失敗ならピボットまたは破棄

### 5. `/agile-story-to-task` — タスク分解

リファインメント済みの Story Issue を、CodingAgent が着手可能な Task Issue に分解する。

- 1 Task Issue = 1 PR 単位で分割
- 各 Task Issue に振る舞い仕様・テスト設計・受入確認を含め、親 Story Issue を読まなくても実装できるレベルにする
- テストピラミッド（ユニット中心・E2E 最小限）に基づくテスト設計

### 6. `/agile-task-implementation` — 実装

Task Issue を XP ペアプログラミング体制で実装し、Draft PR を作成する。

- **役割分担**: ユーザー = ナビゲーター（戦略判断）、Claude = ドライバー（コード記述）
- **フロー**: Task Issue 読み込み → Plan mode で計画 → ナビゲーター承認 → TDD 実装 → 検証 → Draft PR
- 計画承認後はドライバーが一気通貫で実装。行き詰まったときだけナビゲーターに相談

> 注: Issue / PR の作成自体は内部的に `/agile-create-issue` / `/agile-create-pull-request` に委譲される。これらは個別に呼ぶ必要はないが、`gh skill install` 時には個別インストールが必要。

## Issue 分類体系

| カテゴリ | 分類方法 |
|---------|--------|
| 階層 | Issue Type: `Epic Issue`, `Story Issue`, `Task Issue`（Organization 設定で管理） |
| 性質 | ラベル: `nature:implementable`, `nature:experimental` |
| 状態 | GitHub Projects の Status フィールド（下記参照） |

### GitHub Projects のビュー

チケットの状態は GitHub Projects (v2) で管理する。プロジェクトに Status フィールドを作成し、後述の 7 つのオプションを設定する。

運用しやすくするため、用途別にビューを 2 つ用意することを推奨する:

- **仕様策定中のチケット** — `In Planning` / `In Plan Refinement` / `In Plan Review` でフィルタ。PdO が仕様を固めるフェーズ
- **コーディング待ちのチケット** — `Ready` / `In Coding Progress` / `In Code Review` でフィルタ。CodingAgent が実装するフェーズ

プロジェクト固有値（Owner、Project ID、Status Field ID、Status Option ID）は `shared/references/github-projects.md.template` を参考に `~/.claude/skills/references/github-projects.md`（または利用先プロジェクトの `.claude/skills/references/github-projects.md`）を作成する。

### Status フロー

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

## 日常の回し方

```
定例（軽い同期）
  ├── 完了した Story Issue の確認
  ├── 次に取り組む Story Issue のピック
  ├── 必要ならリファインメント実施（/agile-refine-backlog）
  └── 新しい気づきがあれば Epic / VISION の見直しを提案
```

CodingAgent に渡した後は Task Issue 単位で PR が出てくるので、レビュー → マージの流れ。

## Story Issue テンプレート

`agile-create-backlog` と `agile-refine-backlog` で共通のテンプレートを使い、段階的に TBD を埋めていく。

テンプレートの解決順序は agile-* 系の 3 段階解決ロジックに従う:

1. リポジトリの `.github/ISSUE_TEMPLATE/story.md` を最優先
2. 無ければ `agile-create-backlog/templates/story.md`（同梱）をフォールバック
3. フォールバック使用時はリポジトリへの登録確認を行う

**create-backlog 段階で埋める項目**: ストーリー文、概要、粗い受入基準、ラベル

**refine-backlog 段階で埋める項目**: シーケンス図、画面遷移、画面仕様（正常系 / 異常系 / API 仕様）、詳細な受入基準、ロギング
