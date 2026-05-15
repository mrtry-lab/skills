# Browser 自動化指示書 — Iteration Field 作成

Chrome 拡張 (Claude for Chrome 等) で Claude にブラウザ操作を実行させるための指示書。`agile-setup-project` Step 5 の Iteration field 作成を Web UI 経由で行う場合の手順 (GraphQL で作る方が早いので通常は不要、UI でしか操作できないチームポリシーがある場合のみ使う)。

**対象**: GitHub Projects v2 → Project Settings → Fields
**所要**: 2-3 分
**権限**: Project の admin

---

## 入力 (skill から受け取る)

| 変数 | 例 | 入手元 |
|---|---|---|
| `<ORG>` | `mrtry-lab` | Step 1 |
| `<NUMBER>` | `3` | Step 4 |

duration は **180 日固定** (約半年)。日付ベースの auto-advance を実質起こさないための長め固定で、preset 選択は行わない。

---

## 実行手順

### Step 1. Project Settings の Fields ページに移動

URL: `https://github.com/orgs/<ORG>/projects/<NUMBER>/settings/fields`

ページ右上「New field」ボタンを確認する。

### Step 2. Iteration field を追加

1. 「New field」ボタンをクリック
2. Field name: `Iteration` を入力
3. Field type: `Iteration` を選択
4. Duration: **180** (半年固定) を入力
5. Starts on: 起点日 (今日)。デフォルトは今日
6. 「Save」をクリック

### Step 3. 初回 iteration の確認

Iteration field が作成されると、自動で「Iteration 1」相当のレコードが 1 つ生成される (start_date は今日、duration は指定値)。
ページに戻って Iteration field をクリックし、`iterations` セクションに 1 件あることを screenshot で確認。

### Step 4. Field ID / Iteration ID の取得

設定ページからは直接コピーできないので、GraphQL で取得する (skill 本体で実行):

```bash
gh api graphql -f query='
{
  organization(login: "<ORG>") {
    projectV2(number: <NUMBER>) {
      field(name: "Iteration") {
        ... on ProjectV2IterationField {
          id
          configuration { iterations { id title startDate } }
        }
      }
    }
  }
}'
```

レスポンスから `id` (= `ITERATION_FIELD_ID`) と `iterations[0].id` (= `CURRENT_ITERATION_ID`) を抽出して skill 呼び出し元に返す。

---

## 失敗時のフォールバック

| 症状 | 対応 |
|---|---|
| 「Iteration」タイプが選択肢にない | GitHub Projects v2 を使っているか確認。古い Projects beta では未対応 |
| 「Save」が押せない | duration が 0 / 空 / 文字列の可能性。180 を入力する |
| 初回 iteration が空のまま | フィールド作成直後は iterations が空のケースあり。GraphQL `updateProjectV2Field` で `iterations: [{ duration: 180, ... }]` を渡して 1 件追加する (skill 側で fallback 処理) |

---

## 設計上の注記: 未来 iteration は pre-create しない

GitHub Projects の Iteration field は、`iterations` リストに未来の iteration を入れておくと date 進行で auto-advance する。本セットアップでは Iteration 1 のみ作り、Iteration 2 以降は事前に作らない。これにより:

- 180 日経って current iteration の期限が切れる → `@current` が空になり Sprint Board は空 (Story が勝手に動くことはない)
- 次 iteration を回したくなったら手動で Iteration 2 を作って `@current` を切り替える
- 「ユーザー操作以外で Story が動かない」設計が成立する
