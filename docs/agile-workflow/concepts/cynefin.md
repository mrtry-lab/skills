# Cynefin と Chaotic 軽量フロー

`agile-create-stories` の nature ラベルは Cynefin ドメインに対応する:

| Cynefin ドメイン | nature ラベル | 行動原則 |
|---|---|---|
| Clear（明白） | `nature:implementable` | sense → categorize → respond（既知のパターンで対応） |
| Complicated（煩雑） | `nature:implementable` | sense → analyze → respond（専門知識で対応） |
| Complex（複雑） | `nature:experimental` | probe → sense → respond（実験で学ぶ） |
| **Chaotic（混沌）** | **`nature:chaotic`** | **act → sense → respond（行動で安定化）** |

Clear と Complicated はパイプライン上区別する実用価値が薄いため、両方を `nature:implementable` でまとめている。Complex と Chaotic は行動原則が明確に違うため別ラベル。

## Chaotic 軽量フロー

通常の `refine-story` → `implementation-plan-to-task` → `task-implementation` を流すと、緊急対応で時間がかかりすぎ、Cynefin Chaotic ドメインの「行動で安定化」原則に反する。Chaotic Story には以下のショートカットを適用:

- **`agile-refine-story`**: Step 1.5 軽量フロー — 受入基準のみ書く + PdO 視点 1 サブエージェントだけ走らせる。Step 2 / 3-4 / 5a-f / Step 7 の通常 Three Amigos 検査はスキップ
- **`agile-decompose-task-from-implementation-plan`**: 分解せず Story を 1 Task として扱い、即 `agile-task-implementation` へ
- **`agile-task-implementation`**: 通常通り。ただし TDD を妥協しない（hotfix → 安定化後にテストを必ず追加）

Status は通常の `In Plan Refinement → In Plan Review → Ready` を経由せず、`Ready` に直接遷移してよい。

## 事後の postmortem は必須

Chaotic は学習機会。安定化後に **別 Issue** として:

- なぜ Chaotic に至ったか（観測抜け / モニタリング不足 / 予防可能だったか）
- 再発防止策（観測強化 / プロセス改善 / 教育）
- 追加すべきテスト（hotfix で慌てて書けなかった部分）

を記録する。これで Chaotic ドメイン → Complicated / Complex への **学習移行** が起きる。postmortem を書かない Chaotic は「ただの慌てた修正」で終わってしまい、組織が学ばない。

## Chaotic 濫用への警戒

「単に急ぎ」「上司が機嫌悪い」「金曜夕方リリース」は Chaotic ではない。Chaotic は **事業継続が損なわれる切迫した状況** に限定する。濫用すると軽量フローの恩恵がなくなり、ただ受入基準が薄い Story が量産される。判定の問いは「いま行動を起こさないと事業や顧客に深刻な被害が出るか」。No なら通常フロー。

`agile-create-stories/references/cynefin-guide.md` に Story 単位での具体的な分類例を記載している。

---

## References

- 📖 [不確実な世界を確実に生きる カネヴィンフレームワークへの招待](https://www.amazon.co.jp/s?k=不確実な世界を確実に生きる+カネヴィン)（コグニティブ・エッジ / 田村洋一）— Cynefin 4 区分（Clear / Complicated / Complex / Chaotic）と行動原則
- 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/) — Complexity 拡張章（Cynefin 4 区分の現代解釈）
