# セットアップと前提条件

## 前提条件

### GitHub 環境
- **Issue Type の登録**: `Epic` / `Story` / `Implementation Plan` / `Task` の 4 つを Organization に登録済みであること
  - 設定箇所: Organization Settings → Planning → Issue types
  - 未登録の場合は skill 実行時にエラーで案内される
- **GitHub Projects (v2)**: ステータス管理用の Project が存在し、Status フィールドに `In Planning` / `In Plan Refinement` / `In Plan Review` / `Ready` / `In Coding Progress` / `In Code Review` / `Awaiting sprint review` / `Done` の 8 オプションを設定。`Awaiting sprint review` は子 Plan/Task が全 Done になった Story が一時滞留する受け入れ確認待ち Status (`/agile-sprint-review` skill で処理)

### ローカル環境
- `gh` CLI（最新版）
- Claude Code
- Node.js（Mermaid バリデーションを使う場合）

---

## チームコンテキストとプリセット閾値

agile-* スキル群の閾値は `~/.claude/skills/references/team-context.json`（または利用先プロジェクトの `.claude/skills/references/team-context.json`）に集約されている。`agile-setup-project` の Step 3 で対話的に生成し、各スキルが実行時に参照する。

### なぜチームコンテキストが必要か

フルタイムチームと副業チームで同じ閾値を使うと、両方とも不適切になる:

- フルタイムチームに「Epic は同時 2-3 個まで」を強制 → 並行で進められる余裕を制限してしまう
- 副業チームに「Vision セッション 2-3 時間」を強制 → 集中持続時間を超えて生産性が下がる

3 つのプリセット（**軽量 / 標準 / 集中**）から選び、必要に応じて個別カスタマイズできる仕組みにしている。

### 3 プリセットの目安

| プリセット | 想定 | 主な閾値 |
|---|---|---|
| **軽量** | 全員副業 / 週合計 20 時間以下 | Epic 2-3 / ペルソナ 1-2 / refine 25-30 分 / Vision 30-60 分 / Example Mapping ルール上限 5 / 質問上限 3 |
| **標準** | フルタイム 1-2 名 + 副業混合 / 週合計 40-80 時間 | Epic 5-7 / ペルソナ 2-3 / refine 30-60 分 / Vision 60-90 分 / ルール上限 7 / 質問上限 5 |
| **集中** | 全員フルタイム / 週合計 100 時間以上 | Epic 10+ / ペルソナ 3-5 / refine 60-90 分 / Vision 2-3 時間 / ルール上限 10 / 質問上限 8 |

### タスク分割単位（プリセットとは独立）

プリセットの 3 種（軽量 / 標準 / 集中）は **稼働時間** の話で、**Task 粒度（1 PR の範囲）** はリポジトリ構成と運用方針で別に決まる。`agile-setup-project` の Step 3 で 3 問ヒアリングし、`team-context.json` に保存する:

1. **リポジトリ構成**: `MONOREPO` / `MULTI_REPO`
2. **機能実装の分割パターン**: `USE_CASE` (モノレポ標準) / `LAYER` (マルチレポ標準) / `COMPONENT` (DDD・マイクロサービス) / `VERTICAL_SLICE` (TDD で半日 1 PR 厳守) / `CUSTOM`
3. **基盤・インフラ系改修の扱い**: `INLINE` (機能 PR に含める) / `SEPARATE_PR` (DB migration 等は別 PR) / `N_A`

`agile-refine-implementation-plan` の Task 分解計画と `agile-decompose-task-from-implementation-plan` の軽量モード分解はこの設定を参照する。詳細は [`shared/references/team-context.json.template`](../../shared/references/team-context.json.template) のテーブルを参照。

### 設定なしでも動く（軽量プリセットがデフォルト）

`team-context.json` が配置されていない場合、agile-* スキル群は **軽量プリセット**（稼働時間 ＋ `USE_CASE` + `INLINE`）をデフォルトとして動作する。最初は team-context なしで始めて、運用しながら必要を感じたタイミングで `agile-setup-project` を再実行（または `team-context.json` を直接編集）する流れで OK。

### 途中変更（チーム拡大 / 縮小）

チームが拡大した（副業 → フルタイム化）/ 縮小した（フルタイム → 副業へ）ときは:

- `team-context.json` を直接編集してプリセットと採用値を更新する
- 既存の Story / Epic は遡及書き換えしない（DoOD と同じ方針）。新規作成分から新しい閾値を適用する

`agile-setup-project` を再実行すると Step 2.5 を含む全ステップが走るので、Project 設定もまとめて見直したいなら有効。

---

## セットアップ手順

`/agile-setup-project` を実行すれば、対話で 1 回流すだけで以下のフローが回る。下記の手動手順は内部で何が起きているかを把握したい / Template 経路が使えない環境用の参考。

### Project Template `mrtry-lab/Agile Project Sample` (Recommended)

agile-* スキル群が前提とする GitHub Project 構成は **公開テンプレート Project として配布されている**。手動で `gh project field-create` を繰り返す代わりに、`copyProjectV2` mutation で 1 リクエスト複製するだけで以下が初期状態で揃う:

- **Status 8 options**: In Planning → In Plan Refinement → In Plan Review → Ready → In Coding Progress → In Code Review → Awaiting sprint review → Done
- **Iteration field**: duration 180 日固定 (auto-advance を避けるため意図的に長め)
- **3 Views**: Backlog (Board, Story の Epic 別 swimlane) / Sprint (Board, Plan/Task の Story 別 swimlane + iteration:@current フィルタ) / Overview (Table, Type 別 + Show hierarchy)
- **Workflows**: Item closed ON / Auto-add to project OFF / Auto-close issue OFF

| 項目 | 値 |
|---|---|
| Template URL | https://github.com/orgs/mrtry-lab/projects/3 |
| Template flags | `public: true` / `template: true` |
| 複製方法 | GraphQL `copyProjectV2(input: { projectId, ownerId, title, includeDraftIssues: false })` |
| 同梱スクリプト | `skills/agile-setup-project/scripts/copy-from-template.sh` |

`/agile-setup-project` の **Step 4 で「Template からコピー」を選択** すれば、上記が自動実行される。複製後は skill が以下 4 つの assertion script で引き継ぎ状況を検査し、**全 OK なら Step 5/6/7 をスキップして Step 8 (JSON 生成) に直行**、不足あれば該当 Step だけ fallback に降りる:

- `assert-status-options.sh` — Status 8 options 揃ってるか
- `assert-iteration-field.sh` — Iteration field の duration=180 / iterations >= 1
- `assert-workflows.sh` — 3 Workflow の有効/無効状態
- `assert-views.sh` — Backlog / Sprint / Overview 揃ってるか

Issue Type (Epic / Story / Implementation Plan / Task) は **Organization レベルの設定で Template には含まれない** ので、別途 `assert-issue-types.sh` で確認 → 未登録なら Step 2 で登録手順を案内。

### Template が使えない場合 (新規作成 / 既存 Project 取り込み)

組織ポリシーで copyProjectV2 が叩けない、別の独自 Project 構成を使いたい等の理由で Template が使えない場合は、`/agile-setup-project` の Step 4 で「新規作成」or「既存 Project を取り込む」を選ぶと、従来通り `gh project field-create` + Web UI 操作で Status / Iteration / Workflows / Views を組み立てる経路に降りる。同 4 つの assertion script で「何が足りないか」を検出して該当 Step だけ実行する設計。

### 1. skill のインストール

```bash
for skill in agile-craft-vision agile-create-epic agile-create-stories \
             agile-refine-story agile-refine-implementation-plan agile-decompose-task-from-implementation-plan \
             agile-implement-task agile-create-issue agile-create-pull-request \
             agile-setup-project agile-update-skills; do
  gh skill install mrtry-lab/skills $skill --agent claude-code --scope user
done
```

> 💡 一括インストール & docs/agile-workflow/ の取得は `/agile-update-skills` を実行する方法もある (`agile-setup-project` 内からも呼ばれる)。

### 2. shared references の配置（JSON 生成）

`agile-setup-project` の Step 7 で同梱スクリプト `generate-github-projects-ref.sh` を実行する流れが標準。手動で行う場合:

```bash
PROJECT_NAME="My Project" \
OWNER="your-org" NUMBER=1 \
PROJECT_ID="PVT_xxxxxxxx" \
STATUS_FIELD_ID="PVTSSF_xxxxxxxx" \
OPT_PLANNING="xxx" OPT_PLAN_REFINEMENT="xxx" OPT_PLAN_REVIEW="xxx" \
OPT_READY="xxx" OPT_CODING="xxx" OPT_CODE_REVIEW="xxx" OPT_DONE="xxx" \
  bash ~/.claude/skills/agile-setup-project/scripts/generate-github-projects-ref.sh
```

スクリプトは `shared/references/github-projects.json.template` を curl で取得し、jq で各値を埋めて `.claude/skills/references/github-projects.json` を生成。未置換のプレースホルダが残っていれば exit 1。

option ID 等は `gh project field-list <NUMBER> --owner <OWNER> --format json` で取得。

> ⚠️ JSON が配置されるまで、ステータス更新を行うスキル (`update-issue-status.sh` を内部で呼ぶもの) は失敗する。

### 3. validate-mermaid スクリプトの配置（Mermaid 検証を使う場合）

`agile-create-epic` / `agile-refine-story` / `agile-refine-implementation-plan` / `agile-create-issue` は Mermaid 図のバリデーションに `validate-mermaid.mjs` を使う。`/agile-update-skills` が `.claude/scripts/validate-mermaid.mjs` に配置するので、通常は別途配置不要。

依存パッケージのインストールは必要:

```bash
npm install --save-dev jsdom@^29 dompurify@2 mermaid@^11
```

スクリプトや依存が見つからない場合、skill は警告を出して検証スキップして続行する（ブロックはしない）。

---

## テンプレート解決ロジック（agile-* 系の 3 段階）

agile-* スキルは Issue / PR を作成する際、本文テンプレを次の順で解決する:

1. **リポジトリ設定を最優先** — `.github/ISSUE_TEMPLATE/<type>.md`（Issue）または `.github/pull_request_template.md`（PR）があればそれを使う
2. **同梱デフォルトをフォールバック** — リポジトリ側に無ければ skill 同梱の `templates/<type>.md` を使う
3. **登録の確認** — フォールバックを使った場合、Issue / PR 作成後に「これをリポジトリに登録しますか？」と確認

テンプレ未整備のリポジトリでも壁なく動作開始でき、必要に応じてテンプレを根付かせていける。
