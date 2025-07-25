# GitHub通知システム

## 概要
WillMeterプロジェクトの月次ビルド・CI/CDシステムのGitHub内通知システム。
Slack通知に代わる、GitHubネイティブな通知機能を提供します。

## 通知方法

### 1. 成功時: コミットコメント
ビルドが成功した場合、最新コミットに詳細なコメントが自動追加されます。

**表示場所**: 
- リポジトリのコミット履歴
- 該当コミットの詳細ページ

**内容例**:
```markdown
## ✅ 月次ヘルスチェック成功

**実行日時**: 2025-01-01 09:00:00 JST
**コミット**: abc1234

### 📊 ビルド・テスト結果

| 項目 | 結果 |
|------|------|
| iOS 18.5 ビルド | ✅ 成功 (45s) |
| テスト実行 | ✅ 25件成功 (32s) |
| コード品質 | 📝 18ファイル / 1,250行 |
| SwiftLint | ⚠️ 0警告 / 0違反 |

[詳細ログを確認](https://github.com/repo/actions/runs/123456)
```

### 2. 失敗時: GitHub Issue作成
ビルドが失敗した場合、詳細なIssueが自動作成されます。

**Issue設定**:
- **タイトル**: `🚨 月次ヘルスチェック失敗 - YYYY-MM-DD`
- **ラベル**: `ci-failure`, `monthly-check`, `priority-high`
- **担当者**: 自動割り当て（オプション）

**内容例**:
```markdown
## ❌ 緊急対応が必要です

**実行日時**: 2025-01-01 09:00:00 JST
**コミット**: [abc1234](https://github.com/repo/commit/abc1234)
**ワークフロー**: [実行結果を確認](https://github.com/repo/actions/runs/123456)

### 🔍 失敗詳細
- **ビルド状態**: failure
- **テスト状態**: skipped
- **SwiftLint違反**: 5件

### 📋 推奨対応アクション
- [ ] Xcodeバージョンの確認
- [ ] iOS Simulator状態の確認  
- [ ] 依存関係の変更確認
- [ ] 手動ビルドでの問題再現
- [ ] SwiftLint違反の修正

### 📊 現在のプロジェクト状態
- **Swiftファイル数**: 18
- **総コード行数**: 1,250

**優先度**: High
```

### 3. GitHub Actions Summary
各ワークフロー実行後に、GitHub Actions Summaryに結果が表示されます。

**表示場所**: GitHub Actions実行結果ページ

**内容**:
- 実行サマリー
- 品質指標
- 関連リンク
- 次回実行予定

## 通知の種類

### 月次ヘルスチェック通知
**頻度**: 毎月1日09:00 JST
**対象**: `monthly-health-check.yml`

- **成功**: コミットコメント + Actions Summary
- **失敗**: Issue作成 + Actions Summary

### iOS互換性マトリックス通知  
**頻度**: 四半期1日10:00 JST
**対象**: `multi-ios-build-matrix.yml`

- **成功**: コミットコメント（マトリックス結果付き）
- **部分失敗**: Issue作成（priority-medium）

### 品質メトリクス通知
**頻度**: 月次ヘルスチェック30分後
**対象**: `quality-metrics-report.yml`

- **結果**: Actions Summary（トレンド分析付き）
- **履歴**: metrics-historyブランチに保存

## GitHub通知の利点

### ✅ 利点
1. **統合性**: GitHubエコシステム内で完結
2. **履歴性**: Issue・コメント履歴として永続保存
3. **検索性**: GitHub検索でCI/CD履歴を検索可能
4. **権限管理**: GitHubのアクセス権限と統合
5. **無料**: 外部サービス不要
6. **自動化**: ラベル・担当者の自動設定
7. **連携**: プルリクエスト・ブランチとの連携

### ⚠️ 考慮点
1. **リアルタイム性**: Slackほどの即座の通知はなし
2. **モバイル通知**: GitHub Mobileアプリ設定に依存
3. **チーム通知**: @mentionでの個別通知設定が必要

## 通知の確認方法

### 日常的な確認
1. **リポジトリページ**: 最新コミットのコメント確認
2. **Issues タブ**: ci-failure ラベルでフィルタ
3. **Actions タブ**: 定期実行ワークフローの確認

### 月次レビュー
1. **Quality Metrics**: trends-analysisブランチの履歴確認
2. **Issue統計**: 月次失敗率の分析
3. **Performance**: ビルド時間トレンドの確認

## 設定とカスタマイズ

### Issue自動作成の無効化
手動実行時にIssue作成を無効化可能：
```yaml
inputs:
  create_issue:
    description: 'Create GitHub issue on failure'
    default: 'false'
```

### ラベルの追加・変更
ワークフローファイル内で簡単に変更可能：
```javascript
labels: ['ci-failure', 'monthly-check', 'priority-high', 'custom-label']
```

### 担当者の自動割り当て
```javascript
assignees: ['username1', 'username2']
```

### 通知頻度の調整
Cronスケジュールで柔軟に設定：
```yaml
schedule:
  - cron: '0 0 1 * *'  # 月次
  - cron: '0 1 1 */3 *'  # 四半期
```

## トラブルシューティング

### コミットコメントが作成されない
**原因**: GitHub Token権限不足
**解決**: リポジトリ設定でActions権限を確認

### Issueが作成されない
**原因**: Issue作成権限なし
**解決**: `github-script` アクションの権限設定を確認

### 重複Issue作成
**対策**: Issue作成前の既存Issue確認ロジック追加
```javascript
// 既存のci-failure issueをチェック
const existingIssues = await github.rest.issues.listForRepo({
  owner: context.repo.owner,
  repo: context.repo.repo,
  labels: 'ci-failure',
  state: 'open'
});
```

## 拡張予定機能

### Phase 1: 基本通知（✅ 実装済み）
- コミットコメント通知
- Issue自動作成
- Actions Summary

### Phase 2: 高度な通知
- [ ] Pull Request自動作成（修正提案）
- [ ] Discussionsでのチーム議論開始
- [ ] Projectボード自動更新

### Phase 3: インテリジェント通知
- [ ] 失敗パターン学習・予測
- [ ] 関連開発者への@mention
- [ ] 修正コード提案

## メンテナンス

### 定期清掃（月次）
- [ ] 解決済みci-failure Issueのクローズ
- [ ] 古いコミットコメントの確認
- [ ] Actions Summary履歴の整理

### 設定見直し（四半期）
- [ ] Issue作成基準の調整
- [ ] ラベル体系の最適化
- [ ] 通知頻度の見直し
- [ ] チーム体制変更への対応

---

**最終更新**: 2025年7月（issue#4対応・Slack通知削除）  
**利用開始**: GitHub通知システム運用開始  
**次回見直し**: 2025年10月