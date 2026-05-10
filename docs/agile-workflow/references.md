# References — agile-* スキル群が参考にしている書籍・記事・フレームワーク

agile-* スキル群は以下のソースを参考に構築されている。各スキルで直接効いているソースは個別の SKILL.md の `## References` セクションに列挙されている。本ファイルは:

- **スキル横断で効いているソース**（Scrum 起源・対話設計・Expansion Pack 全体）の集約
- **全ソースのマスターリスト**と各スキルへの紐付け

を提供する。

凡例:
- 📖 = 書籍
- 🌐 = Web 記事 / Web 公開冊子
- 📄 = 論文 / PDF
- 📦 = フレームワーク / パッケージ

---

## スキル横断で効いているソース

これらは特定の SKILL.md ではなく agile-* 全体の設計思想に影響している:

### 📄 [The New Product Development Game](https://hbr.org/1986/01/the-new-product-development-game)
**Hirotaka Takeuchi & Ikujiro Nonaka, Harvard Business Review, 1986**

Scrum という単語を初めてソフトウェア開発の文脈で使った原典論文。スクラム的価値観の前提（自律性 / 自己組織化 / 多様性 / 越境的学習 / 微妙な統制）を提示している。agile-* が「定例で軽く同期し、Story 単位で実装」スタイルを採用しているのはこの論文の精神に由来。

### 📖 [SCRUMMASTER THE BOOK 優れたスクラムマスターになるための極意](https://www.amazon.co.jp/dp/4798166855)
**Zuzana Šochová（『The Great ScrumMaster: #ScrumMasterWay』日本語版）**

Scrum Master の State of Mind モデルとメタスキル。agile-* は Scrum Master ロールを厳密化していないが、本書の「ファシリテーション・コーチング・ティーチング・メンタリング」という stance がコーチング原則に反映されている。

### 📖 [コーチングアジャイルチームス](https://www.amazon.co.jp/s?k=コーチングアジャイルチームス)
**Lyssa Adkins**

GROW モデル（Goal → Reality → Options → Will）、「答えを書くな問いを投げよ」という対話原則。すべての agile-* スキルの**コーチングの原則**セクションでこの考え方を継承している。

### 📦 [Scrum Guide Expansion Pack](https://scrumexpansion.org/)
**Jeff Sutherland / John Coleman / Ralph Jocham（GitHub: ScrumGuides/ScrumGuide-ExpansionPack）**

agile-* の以下の章はすべて Expansion Pack 由来:

- **Definition of Outcome Done** — 成果定義（Output Done と Outcome Done の二重化）
- **Example Mapping** — 4 色マップによるビジネスルール網羅
- **Three Amigos と並列サブエージェント orchestration** — PdO / Dev / QA の 3 視点独立検査
- **AI 決定境界** — AI and Scrum 拡張の "AI may assist, but humans retain authority over prioritization, acceptance, release"
- **Holistic Testing と Observe 段階** — Discover → Understand → Build → Deploy → Observe
- **Cynefin と Chaotic 軽量フロー** — Complexity 拡張
- **Strategy 性質と Vision 点検** — Strategy as Empirical Capability（Coleman）
- **品質スコアリングの統一** — 経験主義（Empirical）の運用化

各章の詳細は `docs/agile-workflow/concepts/*.md` を参照。

---

## ソースマスターリスト

### Web 記事 / Web 公開冊子

| # | タイトル | 著者 / 出典 | URL |
|---|---|---|---|
| W1 | Opportunity Canvas | Jeff Patton | https://www.jpattonassociates.com/opportunity-canvas/ |
| W2 | Painless Functional Specifications Part 1: Why Bother? | Joel Spolsky | https://www.joelonsoftware.com/2000/10/02/painless-functional-specifications-part-1-why-bother/ |
| W3 | Painless Functional Specifications Part 2: What's a Spec? | Joel Spolsky | https://www.joelonsoftware.com/2000/10/03/painless-functional-specifications-part-2-whats-a-spec/ |
| W4 | Painless Functional Specifications Part 3: But… How? | Joel Spolsky | https://www.joelonsoftware.com/2000/10/04/painless-functional-specifications-part-3-but-how/ |
| W5 | Painless Functional Specifications Part 4: Tips | Joel Spolsky | https://www.joelonsoftware.com/2000/10/15/painless-functional-specifications-part-4-tips/ |
| W6 | Agile Models (Potential Agile Modeling Artifacts) | Scott Ambler | http://www.agilemodeling.com/artifacts/ |
| W7 | The New Product Development Game | Takeuchi & Nonaka, HBR 1986 | https://hbr.org/1986/01/the-new-product-development-game |
| W8 | Story Map Concepts | Jeff Patton, PDF | https://www.jpattonassociates.com/wp-content/uploads/2015/03/story_mapping.pdf |
| W9 | Agile Story Essentials | Jeff Patton, PDF | https://www.jpattonassociates.com/wp-content/uploads/2015/03/story_essentials_quickref.pdf |
| W10 | Product Discovery Immersion | Jeff Patton | https://jpattonassociates.com/product-discovery-immersion/ |
| W11 | Scrum Guide Expansion Pack | Sutherland / Coleman / Jocham | https://scrumexpansion.org/ |

### 書籍

| # | タイトル | 著者 | Amazon |
|---|---|---|---|
| B1 | INSPIRED | Marty Cagan | https://www.amazon.co.jp/s?k=INSPIRED+Marty+Cagan |
| B2 | Clean Agile | Robert C. Martin | https://www.amazon.co.jp/s?k=Clean+Agile+Robert+Martin |
| B3 | アジャイル型プロジェクトマネジメント | Jim Highsmith | https://www.amazon.co.jp/s?k=アジャイル型プロジェクトマネジメント |
| B4 | アジャイルサムライ | Jonathan Rasmusson | https://www.amazon.co.jp/s?k=アジャイルサムライ |
| B5 | アートオブアジャイルデベロップメント | Jim Shore | https://www.amazon.co.jp/s?k=アートオブアジャイルデベロップメント |
| B6 | エクストリームプログラミング入門 | Kent Beck | https://www.amazon.co.jp/s?k=エクストリームプログラミング |
| B7 | コーチングアジャイルチームス | Lyssa Adkins | https://www.amazon.co.jp/s?k=コーチングアジャイルチームス |
| B8 | 不確実な世界を確実に生きる カネヴィンフレームワークへの招待 | コグニティブ・エッジ / 田村洋一 | https://www.amazon.co.jp/s?k=不確実な世界を確実に生きる+カネヴィン |
| B9 | SCRUMMASTER THE BOOK 優れたスクラムマスターになるための極意 | Zuzana Šochová | https://www.amazon.co.jp/dp/4798166855 |

> Amazon URL は B9 を除き暫定で検索 URL（`s?k=...`）を使用。商品ページ ASIN が確認できれば順次直リンクに置き換え可能。

---

## 各スキルへの紐付け

| スキル | 直接効いているソース |
|---|---|
| `agile-product-vision` | B4 アジャイルサムライ / B1 INSPIRED / B7 コーチングアジャイルチームス / 📦 Expansion Pack（Strategy） |
| `agile-epic` | W1 Opportunity Canvas / B1 INSPIRED / W10 Product Discovery Immersion / B5 アートオブアジャイルデベロップメント |
| `agile-create-backlog` | W8 Story Map Concepts / B8 カネヴィン入門 / W9 Agile Story Essentials / B5 アートオブアジャイルデベロップメント / 📦 Expansion Pack（Complexity） |
| `agile-refine-backlog` | W2-W5 Painless Functional Specs / W6 Agile Models / W9 Agile Story Essentials / B1 INSPIRED / 📦 Expansion Pack（Holistic Testing） |
| `agile-story-to-task` | W9 Agile Story Essentials / B3 アジャイル型 PM / 📦 Expansion Pack（Holistic Testing Observe） |
| `agile-task-implementation` | B6 エクストリームプログラミング入門 / B2 Clean Agile / 📦 Expansion Pack（AI and Scrum / Software Engineering Practices） |
| `agile-create-issue` | 📦 Expansion Pack（AI and Scrum 決定境界） |
| `agile-create-pull-request` | 📦 Expansion Pack（AI and Scrum 決定境界） |
| `agile-project-setup` | B4 アジャイルサムライ / 📦 Expansion Pack（Strategy） |

横断ソース（W7 New Product Development Game / B9 SCRUMMASTER THE BOOK / B7 コーチングアジャイルチームス / 📦 Expansion Pack 全体）は本ファイル冒頭で説明している通り、特定スキルではなく全体の設計思想に影響している。
