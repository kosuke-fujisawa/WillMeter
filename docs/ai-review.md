# AIレビュー設定

このリポジトリでは、同一リポジトリ内の非ドラフトPRを作成・更新したときに `.github/workflows/ai-review.yml` が起動し、PR差分をLLMでレビューします。

レビューの実装本体は共有Action [kosuke-fujisawa/ai-review-action](https://github.com/kosuke-fujisawa/ai-review-action) に移行済みで、このリポジトリ側にはワークフロー定義とレビュー指示（`.github/ai-review-instructions.md`）だけを置いています。

## 必須設定

Repository secrets に以下を追加します。

- `OPENAI_API_KEY`: OpenAI APIキー

Repository variables は任意です。

- `AI_REVIEW_MODEL`: 使用するモデル。未設定時は `gpt-5-mini`

## 動作

1. PR差分と `AGENTS.md`、`.github/ai-review-instructions.md` を収集する。
2. OpenAI Responses APIにレビューを依頼する。
3. 同一リポジトリ内PRの場合、PRコメントを作成または更新する。
4. 入力・出力・コメント本文を `ai-review` artifact に保存する。

`OPENAI_API_KEY` が未設定の場合、レビューはスキップされます。

誤検知と利用量を抑えるため、差分は最大60,000文字、出力は最大3,000トークン、指摘は高確信度の `critical`、`high`、`medium` に限定し、最大5件まで返します。artifactの保持期間は3日です。

## ローカル確認

レビューのスクリプトとテストは共有Action側リポジトリにあるため、動作確認は [kosuke-fujisawa/ai-review-action](https://github.com/kosuke-fujisawa/ai-review-action) 側で行います。このリポジトリ側で変更しうるのは `.github/workflows/ai-review.yml` と `.github/ai-review-instructions.md` のみです。
