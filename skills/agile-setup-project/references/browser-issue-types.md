# Browser 自動化指示書 — Organization Issue Types 登録

Chrome 拡張 (Claude for Chrome 等) で Claude にブラウザ操作を実行させるための指示書。`agile-setup-project` Step 2 のユーザー手動操作を代替する。

**対象**: GitHub Organization Settings → Planning → Issue types
**所要**: 2-3 分
**権限**: 対象 Organization の admin

---

## 入力 (skill から受け取る)

| 変数 | 例 | 入手元 |
|---|---|---|
| `<ORG>` | `mrtry-lab` | Step 1 で確認 |

---

## 実行手順

### Step 1. 該当ページに移動

URL: `https://github.com/organizations/<ORG>/settings/issue-types`

### Step 2. 既存の Issue Type を確認

ページの「Issue types」セクションに表示されているものを列挙。以下 4 つが揃っているか確認:

| name | description | 推奨 color | 推奨 icon |
|---|---|---|---|
| `Epic` | プロダクト機会 (Opportunity Canvas) | purple | rocket |
| `Story` | PdO/QA 視点の要件 | blue | journal |
| `Implementation Plan` | Dev リード視点の戦略 | green | code |
| `Task` | 1 PR 単位の実装作業 | gray | check |

### Step 3. 不足分を作成

各不足 Issue Type について順次実行:

1. 「Add issue type」ボタンをクリック
2. `name` 欄に上記の name を入力
3. `description` 欄に上記の description を入力
4. color / icon を選択 (UI に該当オプションがあれば。なければデフォルトで OK)
5. 「Create」または「Save」ボタンをクリック
6. 一覧に反映されたことを確認

### Step 4. 確認とスクショ

4 つすべて揃った状態でページ全体を screenshot。skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| 「Add issue type」ボタンが見当たらない | admin 権限がない可能性。ユーザーに admin であるか確認し、否なら手動操作に切り替え |
| 保存ボタン押下後にエラー | エラー文をそのまま skill 呼び出し元にエスカレーション。skill 側で手動案内に fallback |
| 既に同名の Issue Type が存在 | 重複作成しない。description / color の更新が必要なら別途 admin 操作 |
