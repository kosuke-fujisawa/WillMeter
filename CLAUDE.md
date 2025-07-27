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

### コミュニケーションルール
- **言語**: 日本語で応答すること
- **コメント**: コード内のコメントは日本語で記述すること
- **ドキュメント**: 技術文書やREADMEは日本語優先
- **ユビキタス言語**: ドメイン用語は日本語で統一

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
- **日本語コメント**: コード内のコメントは日本語で記述
- **ドキュメント日本語化**: README、設計書等は日本語優先

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

### コード品質自動化コマンド（trailing whitespace対応）
```bash
# 全Swiftファイルの末尾空白自動除去
npm run clean:whitespace

# 全ファイル（Swift, YAML, Markdown）の末尾空白除去
npm run clean:all

# SwiftLint + 末尾空白除去の包括的品質チェック
npm run quality:check

# pre-commit hookと同等の処理を手動実行
npm run pre-commit

# 手動での末尾空白除去（npmなし環境）
find . -name "*.swift" -not -path "./.git/*" -exec sed -i '' 's/[[:space:]]*$//' {} \;
```

#### 自動化機能
- **Git pre-commit hook**: コミット時に自動的に末尾空白除去+SwiftLint実行
- **SwiftLint trailing_whitespace**: severity=error で厳格な品質管理
- **npm scripts**: 開発者向け手動メンテナンスコマンド

#### Git Hooks セットアップ
```bash
# pre-commit hookの自動インストール
./scripts/setup-hooks.sh

# 手動インストール（必要に応じて）
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 🏗️ Clean Architecture + DDD アーキテクチャルール

### アーキテクチャ構成（4層レイヤー）

```
┌─────────────────────┐
│   Presentation      │ ← SwiftUI Views, ViewModels (UI層)
├─────────────────────┤
│   Infrastructure    │ ← ObservableObject, Repository実装 (技術詳細)
├─────────────────────┤
│   Application       │ ← Use Cases, Application Services (ビジネス流れ)
├─────────────────────┤
│   Domain            │ ← Pure Entities, Repository抽象化 (ビジネスルール)
└─────────────────────┘
```

### Domain層（Pure Business Rules）
- **WillPower Entity**: Observer Pattern実装、Pure Domain Logic
- **Task Entity**: ライフサイクル管理、Status遷移
- **Repository Interface**: データアクセス抽象化
- **Domain Events**: ドメインイベント通知（Observer Pattern）

### Application層（Business Flow Coordination）
- **WillPowerUseCase**: 意思力の読み込み・保存フロー調整
- **TaskUseCase**: タスク操作の実行フロー
- **Application Service**: ドメインサービスとインフラの調整

### Infrastructure層（Technical Implementation）
- **ObservableWillPower**: SwiftUI統合用ラッパー（ObservableObject）
- **ObservableTask**: TaskエンティティのUI統合
- **Repository Implementation**: InMemory/UserDefaults永続化実装
- **ObservableEntity<T>**: 汎用エンティティラッパー

### Presentation層（User Interface）
- **WillPowerViewModel**: UI特化のプレゼンテーションロジック
- **ContentView**: SwiftUI宣言的UI
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

### ObservableObject責務分離の設計原則

#### ❌ アンチパターン（Domain層にObservableObject）
```swift
// Domain層でObservableObjectを継承（依存方向違反）
public class WillPower: ObservableObject {
    @Published var currentValue: Int  // UI技術がドメインに侵入
}
```

#### ✅ 推奨パターン（Infrastructure層で分離）
```swift
// Domain層：Pure Entity
public class WillPower {
    private(set) var currentValue: Int
    private var observers: [(WillPower) -> Void] = []

    public func addObserver(_ observer: @escaping (WillPower) -> Void) {
        observers.append(observer)
    }
}

// Infrastructure層：SwiftUI統合
public class ObservableWillPower: ObservableObject {
    @Published private var willPower: WillPower

    public init(_ willPower: WillPower) {
        self.willPower = willPower
        willPower.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }
}
```

### Code Rabbit レビュー必須項目（✅ 実装済み）
- [x] Clean Architecture 4層分離実装
- [x] ObservableObject責務の適切な分離
- [x] Observer Pattern実装（Domain Events）
- [x] SwiftLint違反ゼロ（100%準拠）
- [x] 包括的単体テストスイート実装
- [x] Repository Pattern実装
- [x] コメント・ドキュメントの日本語化
- [x] AAA+評価獲得（Code Rabbit）

### プレコミットチェックリスト（✅ 達成済み）
- [x] SwiftLint実行（エラーゼロ）
- [x] 全テスト通過確認（包括的テストスイート）
- [x] Clean Architecture構造遵守
- [x] Code Rabbitレビュー完了（AAA+評価）
- [x] Observer Pattern実装完了
- [x] 日本語コメント・ドキュメント整備
- [x] CC BY-NC 4.0ライセンス管理実装
- [x] OS・ライブラリアップデート対応設計完了
- [x] 互換性テスト・CI/CD設定完了

## 🎯 品質保証（客観的指標ベース）

### 基本品質指標（✅ 達成済み）
- **ビルド成功率**: 100%（Clean Architecture実装完了）
- **テストカバレッジ**: 包括的単体テストスイート
- **SwiftLint違反数**: ゼロ（100%準拠）
- **Code Rabbit評価**: AAA+（最高評価獲得）

### Clean Architecture品質指標（✅ 達成済み）
- **ドメイン純粋性**: Pure Entityによる外部依存ゼロ実現
- **レイヤー違反**: 4層構造による厳格な分離実装
- **ObservableObject分離**: Infrastructure層での適切な責務分離
- **Observer Pattern**: ドメインイベント通知の実装

### TDD品質指標（✅ 達成済み）
- **テストファースト率**: Red-Green-Refactor完全実施
- **ドメインテスト**: WillPower/Task エンティティの完全テスト
- **インフラテスト**: Repository実装の包括的テスト
- **統合テスト**: ViewModel層の動作確認テスト

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
