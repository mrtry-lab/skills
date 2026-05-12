# AI 決定境界

agile-* スキル群は CodingAgent（AI）主体のパイプラインだが、Scrum Expansion Pack の AI and Scrum が示す原則:

> AI may assist, but humans retain authority over **prioritization**, **acceptance**, **release**.

を受け、AI と人間の権限境界をフェーズ別に明示する。各 SKILL.md の「決定境界」ブロックはこの章のマスター表を参照している。

## 全体マップ

| フェーズ | スキル | AI 自律 | 人間承認必須 | 人間主導 |
|---|---|---|---|---|
| ビジョン策定 | `agile-product-vision` | テンプレ整形・整合サブエージェント | 各 Layer の確定 | ミッション / Not-to-do / トレードオフ |
| Epic 定義 | `agile-epic` | Opportunity Canvas 整形・既存 Issue 検索 | 4 リスク評価結果 / Epic 採否 | トリガー判断・予算感・Outcome 仮説 |
| Story 分解 | `agile-create-backlog` | Story Mapping 整形・候補列挙 | nature 分類 / Story 確定 | リリーススライス選択 |
| リファインメント | `agile-refine-backlog` | シーケンス図作成・網羅性検査・Outcome テーブル整形 | リファインメント完了 / 受入基準確定 | Example Mapping のルール抽出 |
| Task 分解 | `agile-story-to-task` | Sub-issue 分割案・品質スコアリング | 分解粒度確定 | テスト戦略選択 |
| 実装 | `agile-task-implementation` | コーディング・TDD・コミット | Plan mode 計画承認 / Draft PR 提出 | エスカレーション判断 |
| Issue 作成 | `agile-create-issue` | テンプレ適用・本文生成 | Issue 起票実行 | — |
| PR 作成 | `agile-create-pull-request` | テンプレ適用・本文生成・Draft 作成 | Draft → Ready 切り替え | マージ |
| Project 初期化 | `agile-project-setup` | ID 取得・プレースホルダ置換 | Project 作成 / Status オプション登録 | Org 選択 / Issue Type 登録 |

## 3 つの不可侵な人間権限

AI がどれだけ賢くなっても譲ってはいけない境界。逆にいえば、これら以外の作業（テンプレ整形・整合検査・実装・テスト記述）は AI に委ねてよい。

1. **Prioritization（優先度判断）** — 何を作るか / やらないかは人間が決める。AI は候補を提示するまで
2. **Acceptance（受け入れ判断）** — 受入基準・Outcome 仮説の最終判断は人間。AI はチェックを補助
3. **Release（リリース判断）** — PR を Draft → Ready にする / マージするのは人間の決定

## 運用ルール

- AI は承認ゲートに到達したら、必ずユーザーに明示的に承認を聞く（自動進行しない）
- 「全部任せる」「自動で進めて」のような包括的指示があっても、本表の「人間承認必須」「人間主導」列は譲らない。「この点は確認させてください」と返す逃げ道として本表を参照してよい
- 人間が承認を出したら次フェーズへ。承認なしで先に進む実装は事故の元 — 各 SKILL.md の NEVER に該当する

## なぜ「明文化するだけ」で済ませているか

既存の agile-* スキル群はすでに人間判断が必要な箇所をワークフロー上で要求している（Plan mode 承認、リファインメント完了の確認、Draft PR の Ready 切り替えなど）。本章はそれを**横断的に整理して名前を付けている**だけで、新しい承認ゲートを増設していない。運用負荷を増やさず、AI の暴走に対するガードだけを強化する設計。

---

## References

- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — AI and Scrum 章。「AI may assist, but humans retain authority over prioritization, acceptance, release」原則
