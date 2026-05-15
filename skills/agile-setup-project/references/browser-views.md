# Browser 自動化指示書 — Project Views 作成 (Backlog / Sprint / Overview)

Chrome 拡張 (Claude for Chrome 等) で Claude にブラウザ操作を実行させるための指示書。`agile-setup-project` Step 6 のユーザー手動操作を代替する。

**対象**: GitHub Projects v2 → Views
**所要**: 5-8 分
**権限**: Project の admin

---

## 入力 (skill から受け取る)

| 変数 | 例 | 入手元 |
|---|---|---|
| `<ORG>` | `mrtry-lab` | Step 1 で確認 |
| `<NUMBER>` | `5` | Step 3 で確認 |

---

## 前提チェック

### Parent issue フィールドの存在確認

1. 移動: `https://github.com/orgs/<ORG>/projects/<NUMBER>/settings`
2. Fields セクションに「Parent issue」があるか確認
3. 無い場合は「New field」 → タイプ `Parent issue` で追加 → 保存

Parent issue フィールドが無いと、Group by に Parent issue を選べず Backlog / Sprint の階層構造が作れない。

---

## 実行手順

### Step 1. Project ページに移動

URL: `https://github.com/orgs/<ORG>/projects/<NUMBER>`

### Step 1.5. 既存の View を削除

最終的に **Backlog / Sprint / Overview の 3 つだけ** が残る状態にする。デフォルトで作られている View (例: `View 1`, `Table`) はすべて削除する:

1. 上部の View タブで各 View を右クリック (または ⋯ メニュー)
2. 「Delete view」を選択
3. 確認ダイアログで「Delete」を承認

全 View を消すと Project ページが空になるので、続けて Step 2 / 3 / 4 で 3 つの View を作成する。

### Step 2. Backlog View 作成

1. View タブ右側の「+」ボタンをクリック
2. 「New view」を選択
3. 設定:

| 項目 | 値 |
|---|---|
| Name | `Backlog` |
| Layout | **Board** |
| Group by | **Parent issue** |
| Filter | `is:open status:"In Planning","In Plan Refinement","In Plan Review","Ready","In Coding Progress","Awaiting sprint review","Done" type:"Story"` |

4. 「Save changes」をクリック
5. 作成された View の URL を控える: `https://github.com/orgs/<ORG>/projects/<NUMBER>/views/<VIEW_NUMBER>`

### Step 3. Sprint View 作成

1. もう一度 View タブの「+」 → 「New view」
2. 設定:

| 項目 | 値 |
|---|---|
| Name | `Sprint` |
| Layout | **Board** |
| Column by | **Status** (デフォルト) |
| Swimlanes | **Parent issue** (Story ごとに横帯が並ぶ) |
| Filter | `iteration:@current status:"Ready","In Coding Progress","In Code Review","Done" type:"Implementation Plan","Task"` |

3. 「Save changes」をクリック
4. View URL を控える

> 補足: Board layout の `Column by` は SingleSelect 型のフィールド限定なので Status を使う。「Story 別に横帯」は `Swimlanes` で実現する点に注意 (Group by は Table/Roadmap 限定)。Filter は `iteration:@current` で current iteration スコープにするのが要点 — これで PR merge により closed になった Done Task も current iteration の間は Sprint Done 列に残る。前 iteration の subtree (shipped 済み Story 配下) は next iteration に進めば自動で消える。

### Step 4. Overview View 作成

階層付き Table で全 Issue を Type 別に俯瞰するビュー。Backlog (Open Epic 配下の Story) / Sprint (current iteration の Plan/Task) と並ぶ、**全体俯瞰** の役割。closed や Done なものも含めて全件見える状態にする。

1. もう一度 View タブの「+」 → 「New view」
2. 設定:

| 項目 | 値 |
|---|---|
| Name | `Overview` |
| Layout | **Table** |
| Group by | **Type** (Issue Type フィールド) |
| Filter | (空。`is:open` 等は付けない) |
| Show hierarchy | **On** |
| 表示フィールド | Title / Type / Status / Sub-issues progress |

3. 「Save changes」をクリック
4. View URL を控える

> 補足: Group by で **Type** を選ぶと Epic / Story / Implementation Plan / Task ごとにグループ化される。`Show hierarchy` を On にすると親子関係も併せて見える。`Sub-issues progress` フィールドを列に出すと完了率 (例: `1/3 33%`) が表示される。Filter を空にする理由: Overview は履歴含む全件俯瞰の役割なので、`is:open` を付けると closed / Done な Story / Plan / Task が見えなくなり Backlog / Sprint との役割分担が崩れる。

### Step 5. 確認

Backlog / Sprint / Overview の 3 View が View タブに追加されていることを確認。各 URL を skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| 「Parent issue」が Group by の選択肢にない | 前提チェックの Parent issue フィールド追加が抜けている。先に追加してリトライ |
| 「Type」が Group by の選択肢にない | Org に Issue Type が未登録の可能性。Step 2 の Issue Type 確認に戻る |
| Filter 構文エラー | GitHub の最新 Filter syntax をチェック。`status:` / `type:` のクオート / カンマ区切りが正しいか確認 |
| Sub-issues progress 列が見えない | View 右上の「⋯」→「Fields」で `Sub-issues progress` を有効化 |
| Show hierarchy トグルが見つからない | View 設定パネル下部にある。Table レイアウト限定の設定 |
| Save できない (画面が固まる) | ページリロード後にリトライ。それでも駄目なら skill 呼び出し元にエスカレーション |
