# Browser 自動化指示書 — Project Workflows 設定

Chrome 拡張 (Claude for Chrome 等) で Claude にブラウザ操作を実行させるための指示書。`agile-setup-project` Step 5 のユーザー手動操作を代替する。

**対象**: GitHub Projects v2 → Workflows
**所要**: 3-5 分
**権限**: Project の admin

---

## 入力 (skill から受け取る)

| 変数 | 例 | 入手元 |
|---|---|---|
| `<ORG>` | `mrtry-lab` | Step 1 で確認 |
| `<NUMBER>` | `5` | Step 3 で確認 |

---

## 実行手順

### Step 1. Workflows ページに移動

URL: `https://github.com/orgs/<ORG>/projects/<NUMBER>/workflows`

### Step 2. 3 つの Workflow を設定

#### A. **Item closed** — 有効化 (Status を Done に自動遷移)

1. ワークフロー一覧の「Item closed」をクリック
2. 編集パネルで `Set value` セクションを開く
3. Field を `Status`、Value を `Done` に選択
4. 「Save and turn on workflow」ボタンをクリック
5. ワークフロー一覧で「Item closed」のトグルが ON / 緑色 になっていることを確認

#### B. **Auto-close issue / Auto-close parent** — 有効化 (Sub-issue 連鎖 close)

1. 「Auto-close issue」または「Sub-issue closed」（GitHub 側のバージョンで表記が違う場合あり）をクリック
2. 編集パネルが表示されたら、デフォルト設定のまま「Save and turn on workflow」をクリック
3. トグルが ON / 緑色 になっていることを確認

#### C. **Auto-add to project** — 無効化

agile-* スキル群は `agile-create-issue` で明示的に Project へ追加する設計のため、Auto-add は OFF にしておく:

1. 「Auto-add to project」をクリック
2. 「Turn off workflow」ボタンをクリック
3. トグルが OFF / 灰色 になっていることを確認

### Step 3. 全 Workflow の状態を確認

| Workflow | 期待状態 |
|---|---|
| Item closed | ON |
| Auto-close issue / Auto-close parent | ON |
| Auto-add to project | OFF |

ページ全体を screenshot して skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| Workflow 名が UI で見つからない (GitHub の UI 更新で名前が変わった) | 現在表示されている Workflow 一覧をユーザーに見せて、対応する名前を選んでもらう |
| 保存後にエラー表示 | エラー文をそのまま skill 呼び出し元にエスカレーション、手動案内に fallback |
| Sub-issue auto-close Workflow が存在しない (Org の plan で未提供) | スキップしてユーザーに「該当 Workflow が無い」と報告 |
