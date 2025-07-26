# 手動実行・テストガイド

## 概要
WillMeterプロジェクトの月次ビルド・CI/CDシステムの手動実行とテスト手順。

## 前提条件
- GitHubリポジトリへの管理者アクセス権限
- GitHub Issues/Commentsの作成権限

## 🚀 手動実行手順

### 1. 月次ヘルスチェックの手動実行

#### GitHub Actionsでの実行
1. GitHubリポジトリの **Actions** タブにアクセス
2. **"Monthly Health Check & Slack Notification"** ワークフローを選択
3. **"Run workflow"** ボタンをクリック
4. パラメータ設定:
   ```yaml
   ✅ Create GitHub issue on failure: true
   ```
5. **"Run workflow"** で実行開始

#### 実行確認項目
- [ ] ワークフローが正常に開始される
- [ ] iOS 18.5でのビルドが成功する
- [ ] テストが全て通過する（25個のテスト）
- [ ] SwiftLintチェックが完了する
- [ ] GitHubコミットコメントに成功通知が作成される

### 2. 複数iOSバージョンビルドマトリックスの実行

#### 手動実行
1. **"Multi-iOS Version Build Matrix"** ワークフローを選択
2. **"Run workflow"** をクリック
3. パラメータ設定:
   ```yaml
   iOS versions to test: 18.5,17.5
   ```
4. 実行開始

#### 確認項目
- [ ] 複数iOSバージョンでの並列ビルド
- [ ] 互換性マトリックス結果の生成
- [ ] パフォーマンス比較レポート
- [ ] GitHubコミットコメントに結果通知

### 3. 品質メトリクス・トレンド分析の実行

#### 手動実行
1. **"Quality Metrics & Trend Analysis"** ワークフローを選択
2. **"Run workflow"** をクリック
3. パラメータ設定:
   ```yaml
   ✅ Generate trend analysis: true
   ✅ Save metrics to history: true
   ```
4. 実行開始

#### 確認項目
- [ ] コード品質指標の計測
- [ ] 技術負債分析の実行
- [ ] トレンド分析の生成（履歴がある場合）
- [ ] メトリクス履歴ブランチへの保存

## 📋 テスト項目チェックリスト

### GitHub通知テスト

#### 成功時コミットコメントの確認
- [ ] 最新コミットにコメントが追加される
- [ ] メッセージ形式: 成功アイコン（✅）
- [ ] ビルド時間の表示
- [ ] テスト結果数の表示
- [ ] コード品質メトリクスの表示
- [ ] GitHub Actionsへのリンクが機能する

#### 失敗時Issueの確認（意図的失敗テスト）
- [ ] GitHub Issueが自動作成される
- [ ] エラーアイコン（❌）でタイトル
- [ ] 失敗原因の詳細表示
- [ ] 推奨アクションのチェックリスト
- [ ] 適切なラベルが設定される（ci-failure, monthly-check, priority-high）

### ビルド・テスト機能

#### 基本ビルドテスト
```bash
# ローカルでの事前確認
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' build
```

#### 実行項目
- [ ] iOS 18.5 Simulatorでのビルド成功
- [ ] 全テストの通過（25個のテスト）
- [ ] SwiftLint違反数ゼロの確認
- [ ] ビルド成果物の正常生成

### アーティファクト確認

#### GitHub Actionsアーティファクト
- [ ] `ios-18-5-logs`: ビルド・テストログ
- [ ] `build-report-18-5`: JSON形式のビルドレポート
- [ ] `quality-metrics`: 品質指標レポート
- [ ] `compatibility-summary`: 互換性マトリックス

#### アーティファクトの内容確認
```bash
# ダウンロード後の確認例
cat build-report-18-5.json | jq .
cat quality-metrics.json | jq '.metrics'
```

## 🔧 トラブルシューティング

### よくある問題と解決法

#### 1. Slack通知が届かない

**症状**: ワークフローは成功するがSlack通知なし

**診断手順**:
```bash
# Secretsの確認（管理者のみ）
1. Settings → Secrets and variables → Actions
2. SLACK_WEBHOOK_URL の存在確認
```

**解決方法**:
- Webhook URLの再設定
- Slack Appの権限確認
- チャンネル名の確認（`#willmeter-ci`）

#### 2. iOS Simulatorエラー

**症状**: `iOS Simulator not available` エラー

**解決方法**:
```bash
# 利用可能なSimulatorの確認
xcrun simctl list devices | grep iOS
```
- Xcodeバージョンとの整合性確認
- Simulatorの再インストール

#### 3. ビルドタイムアウト

**症状**: ワークフローが時間切れで失敗

**解決方法**:
- ビルドキャッシュの確認
- 並列実行数の調整
- タイムアウト時間の延長

#### 4. SwiftLint違反の急増

**症状**: 予期しないSwiftLint違反数の増加

**診断手順**:
```bash
# ローカルでのSwiftLint実行
swiftlint --reporter json > violations.json
cat violations.json | jq '[.[] | .rule] | group_by(.) | map({rule: .[0], count: length}) | sort_by(.count) | reverse'
```

**解決方法**:
- 違反ルールの詳細確認
- SwiftLint設定の見直し
- コード品質の改善

## 📊 結果の解釈

### 成功基準

#### 月次ヘルスチェック
- **ビルド**: 成功（45秒以内）
- **テスト**: 25個全て通過（60秒以内）
- **SwiftLint**: 違反数0個
- **通知**: Slack送信成功

#### 品質メトリクス
- **テストカバレッジ**: 85%以上
- **平均ファイルサイズ**: 100行以下
- **技術負債スコア**: 20以下
- **アーキテクチャ準拠**: 100%

### アラート基準

#### 緊急対応が必要
- ビルド失敗
- テスト失敗（1個以上）
- SwiftLint エラー（1個以上）

#### 注意が必要
- ビルド時間 > 60秒
- テストカバレッジ < 80%
- SwiftLint 警告 > 5個
- 技術負債スコア > 30

## 📅 定期実行スケジュール

### 自動実行タイミング
```yaml
月次ヘルスチェック:      毎月1日 09:00 JST
品質メトリクス分析:      毎月1日 09:30 JST  
複数iOSビルドマトリックス: 四半期1日 10:00 JST
```

### 手動実行推奨タイミング
- **プルリクエスト前**: 品質チェック
- **リリース前**: 全ワークフローの実行
- **月次レビュー前**: トレンド分析の更新
- **障害発生時**: 診断目的での実行

## 🔄 継続的改善

### 月次見直し項目
- [ ] 実行時間の最適化
- [ ] 通知内容の改善
- [ ] メトリクス項目の追加
- [ ] テスト項目の更新

### 四半期見直し項目
- [ ] iOS バージョンサポート範囲
- [ ] 品質基準の調整
- [ ] 新しいCI/CDツールの検討
- [ ] セキュリティ要件の更新

---

**最終更新**: 2025年7月（issue#4対応）  
**次回見直し**: 2025年10月  
**テスト完了確認**: [ ] 全ワークフロー手動実行成功 / [ ] Slack通知動作確認