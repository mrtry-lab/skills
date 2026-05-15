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

issue を手動 close した場合に Project の Status を Done に同期する片方向同期。逆方向 (Status=Done → issue close) は `Auto-close issue` Workflow が担うが、本 skill 群では agile-sprint-review が Story の close を制御するためその Workflow は OFF にする (下記 C 参照)。

#### B. **Auto-add to project** — 無効化

agile-* スキル群は `agile-create-issue` で明示的に Project へ追加する設計のため、Auto-add は OFF にしておく:

1. 「Auto-add to project」をクリック
2. 「Turn off workflow」ボタンをクリック
3. トグルが OFF / 灰色 になっていることを確認

#### C. **Auto-close issue** — 無効化 (Story の close は agile-sprint-review が制御するため)

Status=Done への遷移で issue を自動 close すると、Story が Done になった瞬間に Backlog View から消えてしまう。本 skill 群の運用では:

- Story Done = まだ active (Backlog に残る)
- Epic close 時に cascade で Story も close (Backlog から外れる)

の 2 段階を `/agile-sprint-review` skill が制御する。なので `Auto-close issue` Workflow は OFF にする:

1. 「Auto-close issue」をクリック
2. 「Turn off workflow」ボタンをクリック (既に ON なら、デフォルト OFF なら不要)
3. トグルが OFF / 灰色 になっていることを確認

> 注: Plan/Task の close は PR merge の「Closes #N」リンクで GitHub 標準機能として行われるので、この Workflow を OFF にしても問題なし。

### Step 3. 全 Workflow の状態を確認

| Workflow | 期待状態 |
|---|---|
| Item closed | ON |
| Auto-add to project | OFF |
| Auto-close issue | OFF |

ページ全体を screenshot して skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| Workflow 名が UI で見つからない (GitHub の UI 更新で名前が変わった) | 現在表示されている Workflow 一覧をユーザーに見せて、対応する名前を選んでもらう |
| 保存後にエラー表示 | エラー文をそのまま skill 呼び出し元にエスカレーション、手動案内に fallback |
| Sub-issue auto-close Workflow が存在しない (Org の plan で未提供) | スキップしてユーザーに「該当 Workflow が無い」と報告 |
