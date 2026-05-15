# Iteration

GitHub Projects v2 の Iteration field を使って Sprint View をスコープする仕組み。`iteration:@current` filter で「今 iteration の作業」だけを Board に並べる。

## なぜ Iteration を使うか

Sprint View では Plan/Task の進捗を Story 別の Swimlane で追いたい。但し、放置すると以下の問題が出る:

- **PR merge で Task が close されると Sprint から消える** — `is:open` で絞ると Done 列が機能しない
- **closed Story の swimlane が Sprint に居残る** — 配下の Plan が Done で見えると Story (closed) も swimlane ヘッダとして表示
- **「Story を close したら subtree も hide」を実現する filter syntax が GH Projects に無い** — `parent:closed` のような書き方ができない

これら全てを解決するのが **Iteration field でのスコープ**:

| 問題 | Iteration スコープでの解決 |
|---|---|
| Done Task が `is:open` で消える | Filter が `iteration:@current` なので close 状態は無視 |
| closed Story の swimlane 居残り | Plan/Task が次 iteration に進めば一緒に消えるので時間で解決 |
| 「ship したら hide」の表現 | iteration の進行 = 区切り = ship 単位として扱える |

## Iteration field とは

GitHub Projects v2 の組み込み field 型の 1 つ。

- **duration** (整数 / 日数): 1 iteration の長さ。field 作成時に指定 (必須)
- **start_date** (日付): 起点。ここから duration ごとに iteration が連なる
- **iterations** (リスト): 個別の iteration。`{id, title, start_date, duration}` を持つ
- **`@current`**: 現在日付を含む iteration を指す予約語
- **`@previous` / `@next`**: 前後の iteration
- **`@current..@current+3`**: 範囲指定 (現 + 3 つ先まで)

iteration の auto-advance は **日付ベース**。期間が切れたら GitHub が自動的に次 iteration を `@current` に切り替える。明示的な「iteration close」操作は無い。

本 skill 群では future iteration を pre-create しない設計なので、auto-advance 先が存在しない → 期限切れ後は `@current` が空になる (= advance しようがない)。これで「自動で Story が動かない」が成立する。

## 期間は 180 日固定

duration は **180 日 (約半年) 固定**。preset 選択は行わない。

理由: 短期 (週次 / 隔週) duration だと GitHub Projects の date-based auto-advance によって `@current` が勝手に次 iteration に切り替わり、想定していない Story が Sprint Board から外れる事故が起きる。長期固定 + future iteration を **pre-create しない** ことで、`@current` の auto-advance が事実上発火しなくなる:

- 180 日後に current iteration の期限が切れる → `@current` は空になる (= Sprint Board 空)
- 次 iteration を回したくなったタイミングで手動で次 iteration を作成 → `@current` が切り替わる

これで「ユーザー操作以外で Story が動かない」設計が成立する。

duration 180 は `github-projects.json` の `iteration_field.duration_days` に固定値として記録される。

## 運用パターン

- 180 日経って `@current` が空になる
  - 次 iteration を回したいなら、Web UI から手動で次 iteration を作成。`@current` が切り替わって前 iteration の subtree は Sprint から外れる
  - 個人開発 / 副業 / 探索フェーズに向く緩いリズム
- 期間中に完了しなかった Plan/Task を次 iteration に **手動で carry-over** する場合
  - Sprint Board でドラッグ、または `set-issue-iteration.sh` で個別更新

## 起票時の自動セット

`agile-create-issue` Step 6 が `set-issue-iteration.sh` を呼んで Implementation Plan / Task に current iteration をセットする。これにより:

- Plan/Task は起票直後から Sprint View の current iteration に並ぶ (= Ready 入り = 即 Sprint 投入)
- ユーザーは iteration を意識せずに `/agile-create-issue` を呼べる
- Epic / Story は iteration をセットしない (Sprint View に出さない設計、iteration 概念に乗らない)

スクリプトは `github-projects.json` の `iteration_field.current_iteration_id` を参照する。値が未設定なら警告を出して起票自体は成功させる (起票後の手動 fallback を案内)。

## Story の Done と `/agile-sprint-review`

Story を Done にするタイミング = `/agile-sprint-review` で OK 判定したとき。

- skill が Story Status=Done に進める + 配下 Plan/Task の iteration をクリアする → Sprint Board から subtree が落ちる
- Iteration は外せばよいだけなので、Story を closed にする / しないは GitHub の close state として独立。Sprint 表示は iteration field の値だけで決まる

「Story を close したら subtree も hide」のような cascade close ロジックは要らない。iteration クリアと Status 遷移で同じ結果が得られる。

## 既存 Project の migration

`iteration_field` が設定されていない (= v2 以前の setup) 既存 Project は以下が必要:

1. Project Settings で Iteration field を追加 (`browser-iteration-field.md` 参照)、duration は 180 日
2. 全 Plan/Task に current iteration をセット (`set-issue-iteration.sh` を一括で呼ぶ)
3. `github-projects.json` を再生成 (`generate-github-projects-ref.sh` を新 env vars 付きで実行)
4. Sprint View Filter を `iteration:@current ...` に書き換え
5. Status field に `Awaiting sprint review` option を追加 (既存 option の id を保持しつつ `updateProjectV2Field` で全 option を渡し直す)
6. Backlog View Filter に `Awaiting sprint review` を含める

setup スキルを再実行すれば対話的に進められる。

## 参考

- `shared/references/github-projects.json.template` — `iteration_field` セクション
- `skills/agile-setup-project/SKILL.md` Step 5 — iteration field 作成手順
- `skills/agile-setup-project/references/browser-iteration-field.md` — Web UI 操作 fallback
- `skills/agile-update-skills/scripts/set-issue-iteration.sh` — 起票後の iteration セット
- [GitHub Docs: Filtering projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects/customizing-views-in-your-project/filtering-projects) — `iteration:@current` 等の filter syntax
