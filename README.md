# skills

Claude Code 用のスキル集。`gh skill install`（GitHub 公式、2026-04 リリース）で個別にインストールして使う。

```bash
gh skill install mrtry-lab/skills <skill-name> --agent claude-code --scope user
```

このリポジトリには **2 系統** の skill がある:

- **`agile-*`** — アジャイル運用ワークフロー専用。Epic→Story→Task→PR の階層、GitHub Projects のステータス管理、テンプレ強制構造を伴う。詳細・前提条件・セットアップは **[docs/agile-workflow.md](docs/agile-workflow.md)** を参照
- **`create-*`（軽量版）** — 普通の GitHub プロジェクト向け。「`.github/` にテンプレあったら使う」程度のシンプルさ。プレースホルダ置換も追加スクリプトも不要

両者は名前空間で分離されており、それぞれ独立してインストールできる。

---

## 同梱スキル一覧

### agile-* — アジャイル運用ファミリー

ワークフロー全体像、前提条件、セットアップ手順は **[docs/agile-workflow.md](docs/agile-workflow.md)** を参照。

| skill | 役割 |
|---|---|
| [agile-product-vision](skills/agile-product-vision/) | `docs/VISION.md` を対話で作成・更新 |
| [agile-epic](skills/agile-epic/) | Opportunity Canvas で Epic Issue を作成 |
| [agile-create-backlog](skills/agile-create-backlog/) | Epic を Story Mapping + Cynefin 分類で Story Issue 化 |
| [agile-refine-backlog](skills/agile-refine-backlog/) | Story の要件を実装可能なレベルまで詳細化 |
| [agile-story-to-task](skills/agile-story-to-task/) | リファインメント済み Story を Task Sub-issue に分解 |
| [agile-task-implementation](skills/agile-task-implementation/) | Task Issue → Plan → TDD → Draft PR |
| [agile-create-issue](skills/agile-create-issue/) | agile-* から呼ばれる Issue 作成共通スキル |
| [agile-create-pull-request](skills/agile-create-pull-request/) | agile-* から呼ばれる PR 作成共通スキル |

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
