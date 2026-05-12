# Three Amigos と並列サブエージェント orchestration

Three Amigos は **PdO（プロダクトオーナー）/ Dev（開発者）/ QA（テスト）** の 3 視点でストーリーを検査するプラクティス。歴史的には Example Mapping の起源でもあり、本ガイドでも Step 5f のルール抽出時に 3 視点で問う流れを採用している。

`agile-refine-backlog` は Step 7 の網羅性検査で **3 視点を独立サブエージェントとして並列実行する** orchestration パターンを採用している。

## なぜ 1 サブエージェントではなく並列 3 つなのか

「Dev 視点と QA 視点を 1 つのサブエージェントにまとめてもよいのでは」と考えがちだが、これは Three Amigos の本旨を損なう:

- **視点の独立性が価値の源泉** — 異なる視点が互いを揺さぶり、欠落を浮き彫りにする。視点をマージすると、片方が他方を弱めて平均化される
- **単一 LLM の認知空間は有限** — 「Dev/QA 両方の視点で網羅性を検査して」と頼むと、LLM は無意識に視点を混ぜて両方を中途半端に評価してしまう
- **並列実行はコンテキスト的にも軽い** — サブエージェント呼び出しを 3 つ並列で立ち上げるコストは、メインのコンテキストに 3 視点ぶんの観点を抱え込ませるコストよりずっと小さい

## 視点ごとの責務

| 視点 | 担当 | 観点 |
|---|---|---|
| **PdO** | ユーザー価値・ビジョン整合・Not-to-do 衝突 | 価値の単一性、Outcome Done の妥当性、Not-to-do 違反の混入 |
| **Dev** | 実装可能性・技術的整合性 | アクター網羅、画面 / API 仕様、前提条件、ロギング判定、観測手段の実現性 |
| **QA** | テスタビリティ・受入確認 | パターン → 受入基準の対応、異常系対処、手動受入確認、ルール網羅、観測タイミング |

各サブエージェントには「他視点には踏み込まない」と明示する。Dev 視点が「これはビジネス価値が薄い」と言い始めると Three Amigos が壊れる。

## 結果統合のルール

主エージェントは結果を**マージしない**。3 視点を別セクションでユーザーに提示し:

- 視点間で矛盾する指摘（例: PdO「Not-to-do 違反」 vs Dev「実装は容易」）→ それ自体を論点として浮き上がらせ、採否はユーザーが判断
- 1 視点だけ未解消 → その視点だけ再起動。OK 判定の視点は再検査しない（コンテキスト節約）

## Step 2 との分担

`agile-refine-backlog` には PdO 視点が 2 箇所登場するが、目的が異なる:

| ステップ | 目的 |
|---|---|
| **Step 2 ビジョン整合レビュー** | **事前判定**: そもそもこのストーリーをリファインメントすべきか |
| **Step 7 Sub-agent A**（PdO 視点） | **事後検証**: リファインメント過程で価値仮説からズレていないか |

両方を残すのは、リファインメントは時間のかかる作業で、開始時に整合していても完了時にズレる可能性があるため。

---

## References

- 🌐 [Introducing the Three Amigos](https://www.agilealliance.org/resources/sessions/introducing-the-three-amigos/)（George Dinwiddie, Agile Alliance）— Three Amigos プラクティスの起源
- 🌐 [Introducing Example Mapping](https://cucumber.io/blog/bdd/example-mapping-introduction/)（Matt Wynne, Cucumber Blog）— Example Mapping = Three Amigos の運用形態
- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Holistic Testing 章。Three Amigos を Understand 段階の標準活動として取り込んでいる
