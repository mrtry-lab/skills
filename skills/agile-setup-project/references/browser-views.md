# Browser 自動化指示書 — Project Views 作成 (Backlog / Sprint)

Chrome 拡張 (Claude for Chrome 等) で Claude にブラウザ操作を実行させるための指示書。`agile-setup-project` Step 6 のユーザー手動操作を代替する。

**対象**: GitHub Projects v2 → Views
**所要**: 3-5 分
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

最終的に **Backlog / Sprint の 2 つだけ** が残る状態にする。デフォルトで作られている View (例: `View 1`, `Table`) はすべて削除する:

1. 上部の View タブで各 View を右クリック (または ⋯ メニュー)
2. 「Delete view」を選択
3. 確認ダイアログで「Delete」を承認

全 View を消すと Project ページが空になるので、続けて Step 2 / 3 で Backlog / Sprint を作成する。

### Step 2. Backlog View 作成

1. View タブ右側の「+」ボタンをクリック
2. 「New view」を選択
3. 設定:

| 項目 | 値 |
|---|---|
| Name | `Backlog` |
| Layout | **Board** |
| Group by | **Parent issue** |
| Filter | `is:open status:"In Planning","In Plan Refinement","In Plan Review","Ready","In Coding Progress","Done" type:"Epic","Story"` |

4. 「Save changes」をクリック
5. 作成された View の URL を控える: `https://github.com/orgs/<ORG>/projects/<NUMBER>/views/<VIEW_NUMBER>`

### Step 3. Sprint View 作成

1. もう一度 View タブの「+」 → 「New view」
2. 設定:

| 項目 | 値 |
|---|---|
| Name | `Sprint` |
| Layout | **Board** |
| Group by | **Parent issue** |
| Filter | `status:"Ready","In Coding Progress","In Code Review","Done" type:"Story","Implementation Plan","Task"` |

3. 「Save changes」をクリック
4. View URL を控える

### Step 4. 確認

Backlog / Sprint の 2 View が View タブに追加されていることを確認。各 URL を skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| 「Parent issue」が Group by の選択肢にない | 前提チェックの Parent issue フィールド追加が抜けている。先に追加してリトライ |
| Filter 構文エラー | GitHub の最新 Filter syntax をチェック。`status:` のクオート / カンマ区切りが正しいか確認 |
| Save できない (画面が固まる) | ページリロード後にリトライ。それでも駄目なら skill 呼び出し元にエスカレーション |
