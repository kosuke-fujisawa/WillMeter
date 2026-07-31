# AIレビュー設定

同一リポジトリ内の非ドラフトPRを作成・更新すると、`.github/workflows/ai-review.yml` がPR-Agent v0.35.0を実行します。`skip-ai-review` ラベルを付けたPRは自動レビューしません。

## 必須設定

- Repository secret `OPENAI_API_KEY`: OpenAI APIキー
- Repository variable `AI_REVIEW_MODEL`: 任意。未設定時は `gpt-5-mini`

## 動作

- PR作成・更新時にレビュー、説明生成、改善提案を自動実行する。
- Repository owner、member、collaboratorはPRコメントからPR-Agentコマンドを実行できる。
- レビュー設定と固有指示は `.pr_agent.toml` で管理する。
- PR-Agentはv0.35.0の検証済みcommit SHAへ固定する。

独自Action `kosuke-fujisawa/ai-review-action` と `.github/ai-review-instructions.md` は使用しません。
