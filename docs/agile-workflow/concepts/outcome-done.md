# Definition of Outcome Done

「実装が完了した（Output Done）」と「価値が出た（Outcome Done）」は別物として扱う。受入基準を満たすコードが書けたかどうかと、ユーザーの行動が変わったかどうかは別の問いで、後者を逸さないために agile-* は両方を明示的に記録する。

## 階層と粒度

| レベル | 既存の指標 | Outcome Done で追加する観点 |
|---|---|---|
| Vision | 成功指標（行動ベース） | 「指標が動いた → なぜそうなった」を説明する**因果仮説**と**観測手段** |
| Epic | 成功指標 / ビジネスインパクト | 上記に加えて**観測期間**と**動かなかった場合の学び** |
| Story | 受入基準（Output Done） | **Outcome Done テーブル**: 観測指標 / 期待する変化 / 観測タイミング / 観測手段 |

Story 単位の Outcome Done は、親 Epic の Outcome 仮説テーブルから「このストーリーが寄与する範囲」を引き継いで具体化する。

## 受入基準と Outcome Done の分離

| | 受入基準（Output Done） | Outcome Done |
|---|---|---|
| 判定方法 | 自動テスト・手動確認 | ロギング・分析・観測 |
| 判定タイミング | PR マージ時 | リリース後（即時 / 数日 / 数週） |
| 失敗時の扱い | 実装やり直し | 学びとして記録、Story 改修・廃止・仮説修正 |

混ぜて書くと CodingAgent が「指標が動くかどうか」をテスト条件と誤解しやすい。SKILL.md とテンプレートで意図的にセクションを分けている。

## 観測しない安全弁

すべてのストーリーに Outcome 仮説を強制するとリファインメントが過剰に重くなる。観測コストが投資に見合わないストーリーは:

```
> 観測しない（理由: 探索的な実装で学習対象が定まっていない / 内部的な改修でユーザー体験変化なし / etc）
```

の一行で残してよい。仮説検証しないなら学習も期待しないというトレードオフを明示しているだけで、罪ではない。

## Outcome が動かなかったときの運用

仮説の反証は失敗ではなく**学び**として扱う。次のいずれかを選ぶ:

- **仮説修正**: 因果モデルを書き直して別の Story を作る
- **Story 廃止**: 価値仮説が崩れたなら撤退（コードを残すか削るかは別判断）
- **Story 改修**: 別アプローチで同じ Outcome を狙う

ここで重要なのは「動かなかった」ことを観測できる作りに最初からしておくこと。これが Step 5e と Step 5c（ロギング）の整合性を網羅性検査で確認する理由。

## Outcome Done と既存 Issue

既存の Story / Epic / VISION は遡及書き換えしない。新規作成からのみ Outcome 仮説を必須化する方針で、既存資産の改修コストを払わずに段階的に置き換える。

---

## References

- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Definition of Outcome Done 章。Output Done と Outcome Done の分離概念
- 📖 [Lean Analytics](https://www.amazon.co.jp/s?k=Lean+Analytics)（Alistair Croll / Benjamin Yoskovitz）— Outcome 観測の因果仮説とメトリクス設計
- 📖 [INSPIRED](https://www.amazon.co.jp/s?k=INSPIRED+Marty+Cagan)（Marty Cagan）— Output vs Outcome、価値検証の運用
