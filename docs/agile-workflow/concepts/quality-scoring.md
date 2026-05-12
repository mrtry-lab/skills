# 品質スコアリングの統一

agile-* スキル群は、成果物（Vision / Epic / Story / Task / Implementation Plan / リファインメント済み Story）を確定する **直前** に、共通フォーマットの点数制スコアリングで品質をチェックする設計に揃えている。同じ形が並ぶことで、Claude も人間レビュアも「この時点が確定前ゲートだ」とすぐ認識できる。

## スコアリング配置

| skill | 対象成果物 | 点数 | 合格ライン |
|---|---|---:|---|
| `agile-craft-vision` | VISION.md（5 層完成版） | 8 | 7 / 8 |
| `agile-create-epic` | Epic Issue 起票内容 | 7 | 6 / 7 |
| `agile-create-stories` | Story 提案（候補ごと） | 6 | 5 / 6 |
| `agile-refine-story` | リファインメント完了判定 | 4 + 7 + 6（視点別） | 各視点で個別合格 |
| `agile-decompose-task-from-implementation-plan` | Task 分解結果 | 8 | 7 / 8 |
| `agile-implement-task` | Plan mode 計画 | 6 | 5 / 6 |

`agile-create-issue` / `agile-create-pull-request` / `agile-setup-project` には固有の品質スコアリングを置かない。これらは共通スキル / セットアップ skill で、artefact 品質より「呼ばれた時に正しく振る舞うこと」が責務。

## 統一フォーマット

各 skill のスコアリングセクションは同じ見出し・表構造を採用する:

```markdown
## Step X: 品質スコアリング

{対象成果物} を確定する前に、以下の N 点スコアリングで品質チェックする:

| # | 観点 | 合格基準 |
|---|------|---------|
| ... |

**N 点中 M 点以上で合格。M-1 点以下は書き直し。**
```

## なぜ点数化するのか

- **バイナリ判定で迷わせない**: 「合格 / 不合格」が即座にわかる
- **書き直し基準が明確**: 不合格なら何点足りないかで対話の優先順位がつく
- **AI の自己採点が成立する**: 観点が客観的に判定可能なので、AI が自分で評価して人間に提示できる
- **人間レビュアの負担軽減**: スコアと観点別判定を見れば、長文の出力を読まなくても要点が掴める

## refine-story だけ「視点別合格」になっている理由

リファインメント検査は Three Amigos の 3 視点（PdO / Dev / QA）が並列に走る。視点ごとに独立した観点リストを持つので、合計点数で合否を出すと「Dev 観点は合格だが PdO 観点が壊滅」のような偏りが平均に隠される。**視点ごとに独立合格判定** することで、視点間のバランスが崩れた成果物を見逃さない。

## 既存成果物への遡及適用なし

スコアリング導入後に既存の VISION.md / Epic / Story / Task / 計画を遡って採点しなおす運用はしない。新規作成からのみ適用する（Definition of Outcome Done と同じ移行方針）。

---

## References

- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Empirical process 章。検査と適応を成果物確定前のゲートとして配置する考え方
- 🌐 [Definition of Ready - scrum.org](https://www.scrum.org/resources/blog/walking-through-definition-ready) — 確定前ゲートとしての品質基準の運用論
