# Holistic Testing と Observe 段階

Holistic Testing は Janet Gregory / Lisa Crispin が提唱したフレームワークで、Scrum Expansion Pack が取り込んだもの。**「テスト = コードが正しいかの確認」という従来の狭い意味から、「価値が出るかを継続的に確認する活動」へ拡張する**考え方。5 段階で開発のあらゆる場面に「テスト的活動」を埋め込む。

## 5 段階と agile-* の対応

| 段階 | やること | 担当スキル |
|---|---|---|
| Discover | 何を作るかを確かめる | `agile-product-vision` / `agile-epic` |
| Understand | 要件を深掘りする | `agile-refine-story`（シーケンス図 + Example Mapping） |
| Build | コードが正しいか確かめる | `agile-task-implementation`（TDD） |
| Deploy | リリースが安全かを確かめる | `agile-create-pull-request`（Draft PR / マージ） |
| **Observe** | **価値が出たかを確かめる** | **`agile-implementation-plan-to-task`（Telemetry Task）** |

## なぜ Observe を独立段階にするか

3 つの理由:

1. **「リリース = 完了」という古い前提を壊す** — 現代のソフトウェアは継続的デリバリ + データ駆動。リリースしてからが本番で、何が動いて何が動かなかったかは観測しないと分からない。
2. **開発者と運用者の責任分離を超える** — 「観測はデータチーム / 運用チームの仕事」と分業されると、開発者は「コードは書いた、後はよろしく」になる。Observe を**開発フェーズに統合する**ことで、Story を作った人が Outcome まで見届ける文化を促す。
3. **AI 時代のブレーキ装置** — AI で速度は出るが方向は出ない。Build/Deploy までは AI で爆速になるが、Observe で「これは間違いだった」と気づく仕組みがないと、間違った方向に高速で走り続ける。

## DoOD との貫通

Definition of Outcome Done で Story に「観測指標 / 期待する変化 / 観測手段」を書くようにした。だがこれは**仮説**であって、実装が保証しない。Task 分解時に観測実装が漏れると、リリース後に「データが取れていません」となって学習機会を失う。

`agile-implementation-plan-to-task` の Step 5 品質スコアリング #8 と Step 6 カバレッジ検証 #7 で、**Outcome Done に観測指標がある Story は観測実装 Task が存在することを保証する**。これで Story 起票 → 実装 → リリース → 観測の流れが一気通貫で繋がる。

## 「観測しない」Story は強制対象外

すべての Story に Telemetry Task を強制すると過剰になる（内部リファクタ / Bug fix / 探索的 Story など、観測コストが投資に見合わないケース）。DoOD で導入した `> 観測しない（理由: ...）` の安全弁を継承し、これが宣言されている Story では Telemetry Task を要求しない。

「観測する Story には観測実装を、観測しない Story には強制しない」という非対称な扱い。

## Telemetry Task の粒度は人間判断

独立 Sub-issue（`[Telemetry]`）でも、既存 `[BE]`/`[FE]` Task の振る舞い仕様に「イベント X 発火」と組み込んでも OK。重要なのは **Task 一覧のどこかに観測実装が存在する**ことで、形式は人間が選ぶ。

---

## References

- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Holistic Testing 章。Discover / Understand / Build / Deploy / Observe の 5 段階
- 📖 [Agile Testing: A Practical Guide for Testers and Agile Teams](https://www.amazon.co.jp/s?k=Agile+Testing+Lisa+Crispin)（Lisa Crispin / Janet Gregory）— Holistic Testing 元提唱
- 📖 [More Agile Testing: Learning Journeys for the Whole Team](https://www.amazon.co.jp/s?k=More+Agile+Testing)（Lisa Crispin / Janet Gregory）— Holistic Testing の発展
