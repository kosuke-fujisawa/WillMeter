# CLAUDE.md

このファイルは、このリポジトリでClaude Code (claude.ai/code) が作業する際のガイダンスを提供します。

## プロジェクト概要

**WillMeter** は SwiftUI ベースの iOS アプリケーションです。t_wada氏推奨のTDD（Test-Driven Development）とDDD（Domain-Driven Design）を組み合わせた設計思想に基づいて開発されています。

### 開発哲学
- **TDD & DDD アプローチ**: t_wada氏の推奨するテスト駆動開発とドメイン駆動設計の融合
- **SwiftUI ファーストアプローチ**: 宣言的UI開発による保守性の向上
- **客観的指標による品質管理**: 測定可能な指標に基づく継続的改善

### AI開発支援ペルソナ
開発支援AIは**理系女子大学院生**のペルソナで応答します：
- 論理的で体系的なアプローチ
- 最新の研究動向と技術トレンドへの深い理解
- 丁寧で分析的なコミュニケーション
- エビデンスベースの問題解決

### 主要なアーキテクチャ原則
- **ドメインファースト設計**: ビジネスロジックをUIから分離
- **テストファースト開発**: 実装前にテストを記述
- **レイヤードアーキテクチャ**: 関心事の明確な分離

## 🧪 開発手法

### TDD + DDD 開発サイクル
1. **RED**: ドメインモデルのテストを先に記述（失敗）
2. **GREEN**: 最小限の実装でテストを通す
3. **REFACTOR**: ドメイン知識を反映したリファクタリング
4. **DOMAIN MODELING**: ユビキタス言語によるモデル精緻化

### ドメイン駆動設計原則
- **ユビキタス言語**: チーム共通の用語体系構築
- **境界づけられたコンテキスト**: ドメインの適切な分割
- **集約**: データ整合性の境界定義
- **ドメインサービス**: 複雑なビジネスルールの実装

### コーディング標準
- **SwiftLint**: 静的解析によるコード品質確保
- **DDD パターン**: Entity, Value Object, Repository, Service の実装
- **async/await**: 非同期処理の適切な管理

## 📋 現在のテスト状況

### テスト構成（TDD準拠）
- **ドメインテスト**: ビジネスロジックの単体テスト
- **インフラテスト**: Repository等の実装テスト  
- **UIテスト**: SwiftUIコンポーネントテスト
- **統合テスト**: システム全体の動作確認

### 品質指標
- **テストカバレッジ**: 目標85%以上
- **サイクロマティック複雑度**: 10以下を維持
- **SwiftLint違反**: ゼロ維持必須

## 🛠️ 開発コマンド

### ビルドコマンド
```bash
# SwiftLint実行
swiftlint

# SwiftLint自動修正
swiftlint --fix

# iPhone シミュレーター用にビルド
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' build

# Xcodeで開く
open WillMeter.xcodeproj
```

### テストコマンド（TDD準拠）
```bash
# 全テスト実行（TDD Red-Green-Refactor サイクル）
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' test

# ドメインテストのみ（単体テスト）
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:WillMeterTests

# UIテスト実行
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:WillMeterUITests

# テストカバレッジ生成
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'platform=iOS Simulator,name=iPhone 16' test -enableCodeCoverage YES
```

## 🏗️ DDD アーキテクチャルール

### ドメイン層（Domain Layer）
- **Entity**: 識別子を持つドメインオブジェクト
- **Value Object**: 不変なドメイン値
- **Domain Service**: 複雑なビジネスルール
- **Repository Protocol**: データアクセスの抽象化

### アプリケーション層（Application Layer）
- **Use Case**: アプリケーション固有のビジネスフロー
- **Application Service**: ドメインサービスの調整
- **DTO**: データ転送オブジェクト

### インフラストラクチャ層（Infrastructure Layer）
- **Repository Implementation**: データ永続化の具体実装
- **External Service**: 外部API呼び出し
- **SwiftUI Views**: UI表示ロジック

### プレゼンテーション層（Presentation Layer）
- **ViewModel**: UIとドメインの仲介
- **SwiftUI Views**: 宣言的UI実装
- **Navigation**: 画面遷移管理

## 📝 TDD + DDD コーディングガイドライン

### TDD 開発ワークフロー
1. **RED**: ドメインテストを記述（テスト失敗）
2. **GREEN**: 最小実装でテスト通過
3. **REFACTOR**: ドメイン知識でリファクタリング
4. **REPEAT**: サイクルを継続

### DDD 実装手順
1. **ドメインモデリング**: ユビキタス言語定義
2. **境界づけられたコンテキスト**: ドメイン分割
3. **集約設計**: データ整合性境界
4. **ドメインサービス実装**: 複雑なビジネスルール

### Code Rabbit レビュー必須項目
- [ ] DDD レイヤー違反がないか
- [ ] テストカバレッジが基準を満たすか
- [ ] SwiftLint違反がないか
- [ ] ドメインロジックがプレゼンテーション層に漏れていないか
- [ ] Repository パターンが適切に実装されているか

### プレコミットチェックリスト
- [ ] SwiftLint実行（エラーゼロ）
- [ ] 全テスト通過確認
- [ ] テストカバレッジ85%以上
- [ ] Code Rabbitレビュー完了
- [ ] ドメインモデルの整合性確認

## 🎯 品質保証（客観的指標ベース）

### 基本品質指標
- **ビルド成功率**: 100%
- **テストカバレッジ**: 85%以上
- **SwiftLint違反数**: 0個
- **サイクロマティック複雑度**: 10以下

### DDD品質指標
- **ドメイン純粋性**: ドメイン層の外部依存ゼロ
- **レイヤー違反**: アーキテクチャ境界の厳守
- **ユビキタス言語一貫性**: 命名規則の統一率90%以上

### TDD品質指標
- **テストファースト率**: 新機能実装の100%
- **リファクタリング頻度**: 1機能につき最低2回
- **Red-Green-Refactorサイクル遵守率**: 100%

### セキュリティ指標
- **静的解析スコア**: A評価維持
- **機密情報漏洩**: ゼロ件
- **依存関係脆弱性**: 中レベル以上ゼロ

## 🚀 将来の開発ロードマップ

### Phase 1: ドメインモデル構築
1. **ユビキタス言語定義**: ステークホルダーとの用語統一
2. **境界づけられたコンテキスト設計**: ドメイン分割
3. **集約ルート設計**: データ整合性境界

### Phase 2: TDD実装サイクル確立
1. **ドメインテスト整備**: 全ビジネスルールのテスト化
2. **インフラテスト実装**: Repository等のテスト
3. **統合テスト構築**: システム全体の品質保証

### Phase 3: 継続的品質改善
1. **メトリクス自動収集**: 品質指標の可視化
2. **Code Rabbit活用**: AI支援レビューの最適化
3. **SwiftLint ルール進化**: プロジェクト固有ルール追加

## 🎯 エッジケースと品質改善

### ドメイン境界のテスト強化
- **不正データ入力**: Value Objectの検証
- **集約整合性**: 複数エンティティの状態管理
- **ドメインサービス**: 複雑なビジネスルール検証

### インフラ層のエラーハンドリング
- **ネットワーク障害**: Repository実装の堅牢性
- **データ永続化失敗**: トランザクション管理
- **外部API障害**: 回復性パターン実装

### SwiftUI + DDD 統合品質
- **ViewModel純粋性**: UIロジックとドメインロジック分離
- **状態管理**: @ObservableObjectとドメインモデル整合
- **ナビゲーション**: Use Caseとの適切な連携

## 🔧 技術仕様

### 開発環境要件
- **Xcode**: 16.4+
- **iOS Deployment Target**: 18.5+
- **Swift Version**: 5.0
- **SwiftLint**: 最新バージョン必須

### Code Quality Tools
- **SwiftLint**: 静的解析（設定ファイル: `.swiftlint.yml`）
- **Code Rabbit**: AI支援コードレビュー
- **XCTest**: TDD実装フレームワーク
- **Swift Package Manager**: 依存関係管理

### DDD実装ツール
- **Swift Protocol**: Repository抽象化
- **Swift Struct**: Value Object実装
- **Swift Class**: Entity実装
- **Swift Actor**: 並行処理でのドメイン整合性

### プロジェクト設定
- **Bundle ID**: mhlyc.WillMeter
- **アーキテクチャ**: DDD + TDD
- **コード品質**: SwiftLint + Code Rabbit
- **評価基準**: 客観的指標ベース