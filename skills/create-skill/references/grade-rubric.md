# skill-judge Grade Rubric 早見表

skill-judge 本体の評価軸サマリー。`create-skill` の Step 3 (早期ゲート) / Step 7 (最終ゲート) でレポートを解釈する際の参照用。

出典: `softaworks/agent-toolkit/skills/skill-judge/SKILL.md` (canonical)

## 目次

- [Grade スケール](#grade-スケール) — A-F の点数ラインと意味
- [8 次元 (合計 120 点)](#8-次元-合計-120-点) — 各 dim の重みと **本文改変を要求するか** の列
- [D1 (Knowledge Delta) が最重要](#d1-knowledge-delta-が最重要) — 落ちる典型 / 上げる打ち手
- [description の品質チェックリスト (D4)](#description-の品質チェックリスト-d4) — frontmatter の WHAT/WHEN/KEYWORDS
- [レポートから抽出する項目](#レポートから抽出する項目) — skill-judge 出力フォーマット
- [共通 failure pattern](#共通-failure-pattern-skill-judge-が指摘するもの) — 9 種の anti-pattern

## Grade スケール

| Grade | 点数 (120 点満点) | パーセンテージ | 意味 |
|---|---|---|---|
| **A** | 108+ | 90%+ | Excellent — production-ready expert Skill |
| **B** | 96-107 | 80-89% | Good — minor improvements needed |
| **C** | 84-95 | 70-79% | Adequate — clear improvement path |
| **D** | 72-83 | 60-69% | Below Average — significant issues |
| **F** | <72 | <60% | Poor — needs fundamental redesign |

`create-skill` の目標は **Grade A (108+/120)**。

## 8 次元 (合計 120 点)

| Dim | 名前 | 点数 | 何を見るか | 本文改変を要求するか (create-skill Step 9 の分岐に直結) |
|---|---|---|---|---|
| **D1** | Knowledge Delta | **20** | LLM が知らない情報を実際に持ち込めているか (THE CORE) | **要求 (本文)** |
| **D2** | Mindset + Appropriate Procedures | 15 | 規範的な思考/手順を埋め込めているか (e.g. Redlining workflow) | **要求 (本文)** |
| **D3** | Anti-Pattern Quality | 15 | NEVER / アンチパターンが具体的かつ実害ベースで書けているか | **要求 (本文に NEVER 節)** |
| **D4** | Specification Compliance | 15 | **特に frontmatter YAML の `description:` フィールドの品質**。trigger / WHEN / KEYWORDS 明示 | 要求しない (frontmatter のみ) |
| **D5** | Progressive Disclosure | 15 | references / templates / scripts への分離設計 | **要求 (同梱ファイル追加・分離)** |
| **D6** | Freedom Calibration | 15 | 「指示と自由度のバランス」: 4 択 vs 自由記述、テンプレ vs 即興 | **要求 (本文の指示の硬さ)** |
| **D7** | Pattern Recognition | 10 | 既存パターン (Tutorial / Dump / Orphan References 等の anti) を回避できているか | **要求 (本文構造)** |
| **D8** | Practical Usability | 15 | 実際にユーザーが回せる workflow になっているか | **要求 (workflow 節)** |

**本文改変を要求しないのは D4 (15/120 = 12.5%) のみ**。残り 87.5% は本文・章構成・scripts/references の書き換えを要求する可能性があるため、`create-skill` Step 9 では「本文改変あり = Step 6 (skill-creator 挙動評価) に巻き戻し」が原則となる。

## D1 (Knowledge Delta) が最重要

skill-judge は D1 を「The Core Dimension」と呼ぶ。20 点中 16 点未満 (80%) なら、他の dimension が満点でも全体 A は届かない計算になる場面が多い。

**D1 が落ちる典型例**:
- LLM が事前知識で書けてしまう内容しか入っていない (= skill 化する意味がない)
- 「ベストプラクティス一覧」だけで具体的な workflow / hard-won lessons が無い
- 出典なしの一般論

**D1 を上げる打ち手**:
- 過去のインシデントや実プロジェクトの判断を 1-2 件埋め込む
- 「LLM が知らない手順」を明示 (e.g. 社内システムの API、特殊な CLI フラグ)
- ✅ / ❌ ペアの具体例を添える

## description の品質チェックリスト (D4)

**ここでいう "description" は frontmatter YAML の `description:` フィールドのこと** (markdown 本文ではない)。skill-judge D4 によると "THE MOST CRITICAL FIELD — determines if skill gets used at all"。Agent は SKILL.md の本文を見て判定するわけではなく、description だけ見て activation を決めるため。

description は 3 つの問いに答える必要がある:

| 問い | 内容 |
|---|---|
| **WHAT** | この skill は何をするか (機能) |
| **WHEN** | どんな状況で使うか (trigger 文脈) |
| **KEYWORDS** | どんな語が trigger になるか (検索可能語) |

最低限以下を満たす:
- [ ] 具体的な capability を列挙 (「X を助ける」のような抽象は不可)
- [ ] **Use when** で発動条件を明示
- [ ] **Triggers:** で発話例を 5-10 件列挙
- [ ] 類似 skill との差別化点を明示 (重複起動の回避)
- [ ] When NOT to use を本文側に書き、description でも触れる

D4 不足の場合は **本文を触らずに frontmatter description だけ書き換えれば済む** ため、`create-skill` Step 9 では Step 6 (skill-creator 巻き戻し) ではなく Step 7 (skill-judge 再評価) に直行できる。さらに Step 10 の description optimization (skill-creator の `scripts.run_loop`) で trigger 精度を自動最適化できる。

## レポートから抽出する項目

skill-judge の Step 5 (Generate Report) で出力されるフォーマット:

```markdown
# Skill Evaluation Report: [Skill Name]

## Summary
- Total Score: X/120 (X%)
- Grade: [A/B/C/D/F]
- Pattern: [Mindset/Navigation/Philosophy/Process/Tool]
- Knowledge Ratio: E:A:R = X:Y:Z
- Verdict: [One sentence]

## Dimension Scores
| Dimension | Score | Max | Notes |
|---|---|---|---|
| D1 ... | x | 20 | |
...

## Critical Issues
[must-fix problems]

## Top 3 Improvements
1. [highest impact]
2. ...

## Detailed Analysis
[80% 未満の dimension のみ詳細]
```

`create-skill` の Step 3 では **Critical Issues + Top 3 Improvements + 80% 未満の Dimension** を抽出し、Step 5 (取捨選択) に渡す。

## 共通 failure pattern (skill-judge が指摘するもの)

| Pattern | 内容 |
|---|---|
| The Tutorial | チュートリアル的に手順を並べただけ。Skill = 知識外部化のはず |
| The Dump | あらゆる情報を SKILL.md に詰め込み progressive disclosure 不在 |
| The Orphan References | references/ にファイルはあるが SKILL.md から指してない |
| The Checkbox Procedure | 手順は書いてあるが「なぜ」が無い |
| The Vague Warning | NEVER 系が抽象的 (e.g. 「気をつける」) |
| The Invisible Skill | description が貧弱でトリガーされない |
| The Wrong Location | 配置先 / scope を誤る |
| The Over-Engineered | 不要な分岐 / 装飾が多すぎる |
| The Freedom Mismatch | 自由記述すべき箇所を 4 択に、4 択で良い箇所を自由記述に |

これらは Step 5 で指摘として現れたとき、優先度を上げて反映する候補。
