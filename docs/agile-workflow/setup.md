# セットアップと前提条件

## 前提条件

### GitHub 環境
- **Issue Type の登録**: `Epic` / `Story` / `Task` の 3 つを Organization に登録済みであること
  - 設定箇所: Organization Settings → Planning → Issue types
  - 未登録の場合は skill 実行時にエラーで案内される
- **GitHub Projects (v2)**: ステータス管理用の Project が存在し、Status フィールドに `In Planning` / `In Plan Refinement` / `In Plan Review` / `Ready` / `In Coding Progress` / `In Code Review` / `Done` の 7 オプションを設定

### ローカル環境
- `gh` CLI（最新版）
- Claude Code
- Node.js（Mermaid バリデーションを使う場合）

---

## チームコンテキストとプリセット閾値

agile-* スキル群の閾値は `~/.claude/skills/references/team-context.md`（または利用先プロジェクトの `.claude/skills/references/team-context.md`）に集約されている。`agile-project-setup` の Step 2.5 で対話的に生成し、各スキルが実行時に参照する。

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

### 設定なしでも動く（軽量プリセットがデフォルト）

`team-context.md` が配置されていない場合、agile-* スキル群は **軽量プリセット** をデフォルトとして動作する。最初は team-context なしで始めて、運用しながら必要を感じたタイミングで `agile-project-setup` を再実行（または `team-context.md` を直接編集）する流れで OK。

### 途中変更（チーム拡大 / 縮小）

チームが拡大した（副業 → フルタイム化）/ 縮小した（フルタイム → 副業へ）ときは:

- `team-context.md` を直接編集してプリセットと採用値を更新する
- 既存の Story / Epic は遡及書き換えしない（DoOD と同じ方針）。新規作成分から新しい閾値を適用する

`agile-project-setup` を再実行すると Step 2.5 を含む全ステップが走るので、Project 設定もまとめて見直したいなら有効。

---

## セットアップ手順

> 💡 初回セットアップは `/agile-project-setup` スキルを使うと、GitHub Project 作成・Status オプション登録・ビュー作成案内・shared references 生成までを対話で一気通貫で完了できる。下記の手動手順は内部で何が起きているかを把握したい場合の参考。

### 1. skill のインストール

```bash
for skill in agile-product-vision agile-epic agile-create-backlog \
             agile-refine-backlog agile-story-to-task agile-task-implementation \
             agile-create-issue agile-create-pull-request; do
  gh skill install mrtry-lab/skills $skill --agent claude-code --scope user
done
```

### 2. shared references の配置（プレースホルダ置換）

`shared/references/github-projects.md.template` をプロジェクトの `.claude/skills/references/github-projects.md` に配置し、プレースホルダを実値に置換する。

```bash
mkdir -p .claude/skills/references
curl -fsSL https://raw.githubusercontent.com/mrtry-lab/skills/main/shared/references/github-projects.md.template \
  -o .claude/skills/references/github-projects.md

# プロジェクト固有値を取得
gh project field-list <YOUR_PROJECT_NUMBER> --owner <YOUR_GITHUB_ORG> --format json

# プレースホルダ置換（macOS の例）
sed -i '' \
  -e 's|<YOUR_PROJECT_NAME>|My Project|g' \
  -e 's|<YOUR_GITHUB_ORG>|your-org|g' \
  -e 's|<YOUR_PROJECT_NUMBER>|1|g' \
  -e 's|<YOUR_PROJECT_ID>|PVT_xxxxxxxx|g' \
  -e 's|<YOUR_STATUS_FIELD_ID>|PVTSSF_xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_IN_PLANNING>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_IN_PLAN_REFINEMENT>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_IN_PLAN_REVIEW>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_READY>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_IN_CODING_PROGRESS>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_IN_CODE_REVIEW>|xxxxxxxx|g' \
  -e 's|<STATUS_OPTION_ID_DONE>|xxxxxxxx|g' \
  .claude/skills/references/github-projects.md
```

Linux（GNU sed）は `-i ''` ではなく `-i` を使う。

> ⚠️ プレースホルダ置換が完了するまで、ステータス更新を行うスキルを呼ばないこと（未置換文字列のままコマンド実行されてしまう）。

### 3. validate-mermaid スクリプトの配置（Mermaid 検証を使う場合）

`agile-epic` / `agile-refine-backlog` は Mermaid 図のバリデーションに `validate-mermaid.mjs` を使う。`gh skill install` では取得されないので別途配置する。

```bash
mkdir -p .claude/scripts
curl -fsSL https://raw.githubusercontent.com/mrtry-lab/skills/main/scripts/validate-mermaid.mjs \
  -o .claude/scripts/validate-mermaid.mjs
npm install --save-dev jsdom@^29 dompurify@2 mermaid@^11
```

スクリプトが見つからない場合、skill は警告を出して検証スキップして続行する（ブロックはしない）。

---

## テンプレート解決ロジック（agile-* 系の 3 段階）

agile-* スキルは Issue / PR を作成する際、本文テンプレを次の順で解決する:

1. **リポジトリ設定を最優先** — `.github/ISSUE_TEMPLATE/<type>.md`（Issue）または `.github/pull_request_template.md`（PR）があればそれを使う
2. **同梱デフォルトをフォールバック** — リポジトリ側に無ければ skill 同梱の `templates/<type>.md` を使う
3. **登録の確認** — フォールバックを使った場合、Issue / PR 作成後に「これをリポジトリに登録しますか？」と確認

テンプレ未整備のリポジトリでも壁なく動作開始でき、必要に応じてテンプレを根付かせていける。
