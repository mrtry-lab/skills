# Strategy 性質と Vision 点検

Scrum Expansion Pack の Strategy 拡張（**Strategy as Empirical Capability**、John Coleman）は、戦略を「経験主義で扱える能力」として再定義し、良い戦略が満たすべき **10 性質** を提示している。`agile-craft-vision` の Step 4 では、このうち 4 性質を専用サブエージェントで点検する。

## Vision 点検が 2 並列サブエージェントになっている理由

Step 4 は性格の違う 2 種類の検査を扱う:

| 検査 | 視点 |
|---|---|
| 5 層整合レビュー（既存） | 構造的整合性。ミッション ⇄ Not-to-do、トレードオフ ⇄ タイムラインなどの矛盾を見る |
| Strategy 性質点検（追加） | 戦略としての質。同じ Vision が「戦略として強いか」を見る |

性格が違うので 1 サブエージェントに両方やらせると認知が混ざり、片方が他方を弱める（Three Amigos と同じ現象）。並列起動して結果を視点別に提示する。

## 採用した 4 性質

| 性質 | 検査内容 | 想定する事故 |
|---|---|---|
| **Intent**（戦略の継続性） | ミッションに具体策（特定 SaaS 名・特定ライブラリ名）が混ざっていないか | Layer 4 の選択肢を狭める / 短期トレンドにミッションが流される |
| **Focus**（選別の鋭さ） | Not-to-do リストが空 / TBD ばかりではないか | 「全部やる」状態でスコープが膨張 |
| **Coherence**（内的整合性） | 各層が戦略的に矛盾していないか（既存の構造的整合とは別） | 「品質最優先」と謳いつつ「期日固定」を採るような戦略上の不一致 |
| **Memorability**（記憶しやすさ） | エレベーターピッチを 30 秒で言えるか | 書類化されただけで、判断時に誰も思い出さない Vision になる |

## 採用しなかった 6 性質（参考）

| 性質 | 採用しない理由 |
|---|---|
| Differentiation（差別化） | `agile-create-epic` の Opportunity Canvas で十分扱える |
| Hard-to-imitate（模倣困難性） | 初期段階では仮説でしかなく、議論コストが高い |
| Resourcefulness（リソース活用） | 組織能力レベルの抽象論で、プロダクト戦略の Vision には粗すぎる |
| Robustness（堅牢性） | Layer 5 リスクリストおよび 4 リスク評価で部分的にカバー済み |
| Plasticity（柔軟性） | まだ動かしていない段階では検証不能 |
| Sustainability（持続可能性） | 長期視点であり Vision 段階での評価は時期尚早 |

これらは将来チーム規模が拡大した場合や深く戦略を点検したいタイミングで個別に取り入れる余地として残している。

## 定期実行で機能する設計

`agile-craft-vision` は **四半期〜半年で定期実行** する想定。市場・チーム・技術環境の変化に追従するために Vision 自体を見直すたびに、Strategy 点検も自動的に毎回走る。別途 Strategy レビュー専用 skill を作らず Vision に統合した理由はこれで、定期実行のリズムが Strategy 検査のリズムと一致する。

---

## References

- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Strategy as Empirical Capability 章（John Coleman）。戦略の 10 性質と経験主義的な扱い方
- 📖 [Good Strategy Bad Strategy](https://www.amazon.co.jp/s?k=Good+Strategy+Bad+Strategy)（Richard Rumelt）— Diagnosis / Guiding Policy / Coherent Action という戦略の核（Focus / Coherence の原典的議論）
- 📖 [プレイ・バイ・ザ・ルールズ](https://www.amazon.co.jp/s?k=プレイ・バイ・ザ・ルールズ)（Roger L. Martin）— Where to play / How to win の選別（Focus の鋭さの参考）
