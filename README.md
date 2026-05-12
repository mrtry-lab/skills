# skills

Claude Code 用のスキル集。`gh skill install`（GitHub 公式、2026-04 リリース）で個別にインストールして使う。

```bash
gh skill install mrtry-lab/skills <skill-name> --agent claude-code --scope user
```

このリポジトリには **2 系統** の skill がある:

- **`agile-*`** — アジャイル運用ワークフロー専用。Epic→Story→Task→PR の階層、GitHub Projects のステータス管理、テンプレ強制構造を伴う。詳細・前提条件・セットアップは **[docs/agile-workflow/](docs/agile-workflow/)** を参照
- **`create-*`（軽量版）** — 普通の GitHub プロジェクト向け。「`.github/` にテンプレあったら使う」程度のシンプルさ。プレースホルダ置換も追加スクリプトも不要

両者は名前空間で分離されており、それぞれ独立してインストールできる。

---

## 同梱スキル一覧

### agile-* — アジャイル運用ファミリー

ワークフロー全体像、前提条件、セットアップ手順は **[docs/agile-workflow/](docs/agile-workflow/)** を参照。

| skill | 役割 |
|---|---|
| [agile-product-vision](skills/agile-product-vision/) | `docs/VISION.md` を対話で作成・更新 |
| [agile-epic](skills/agile-epic/) | Opportunity Canvas で Epic Issue を作成 |
| [agile-create-stories](skills/agile-create-stories/) | Epic を Story Mapping + Cynefin 分類で Story Issue 化 |
| [agile-refine-story](skills/agile-refine-story/) | Story の要件を PdO/QA 視点で詳細化 (受入基準・Outcome・ビジネスルール) |
| [agile-refine-implementation-plan](skills/agile-refine-implementation-plan/) | Story の sub-issue として Implementation Plan Issue を作成 (技術詳細・API 仕様・Task 分解) |
| [agile-implementation-plan-to-task](skills/agile-implementation-plan-to-task/) | Implementation Plan or 軽量 Story から Task Sub-issue に分解 |
| [agile-task-implementation](skills/agile-task-implementation/) | Task Issue → Plan mode → TDD → Draft PR |
| [agile-create-issue](skills/agile-create-issue/) | agile-* から呼ばれる Issue 作成共通スキル |
| [agile-create-pull-request](skills/agile-create-pull-request/) | agile-* から呼ばれる PR 作成共通スキル |
| [agile-project-setup](skills/agile-project-setup/) | 初回セットアップ用。GitHub Project の作成・Status オプション登録・shared references 生成を対話で完了 |

### 軽量版 — 普通の GitHub プロジェクト向け

| skill | 役割 |
|---|---|
| [create-issue](skills/create-issue/) | `.github/ISSUE_TEMPLATE/` を使ってシンプルに Issue 作成 |
| [create-pull-request](skills/create-pull-request/) | `.github/pull_request_template.md` を使ってシンプルに Draft PR 作成 |

軽量版だけ使う場合:

```bash
gh skill install mrtry-lab/skills create-issue --agent claude-code --scope user
gh skill install mrtry-lab/skills create-pull-request --agent claude-code --scope user
```

軽量版はインストールしてすぐ使える（テンプレが `.github/` にあれば使う、無ければ汎用構造で対話的に作成）。

---

## License

[MIT](LICENSE)
