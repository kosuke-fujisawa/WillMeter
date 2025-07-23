# WillMeter 🎯

> ウィルパワーを可視化して、本当にやりたいことに集中するための意思力管理アプリ

## 概要

**WillMeter** は、ウィルパワー（意思力）を数値として可視化し、日々のタスク決定をサポートする iOS アプリケーションです。限りある意思力を効果的に配分することで、本来自分がやりたかったことや楽しみたいことに集中できるようになり、より充実した日々を送ることを目的としています。

## ✨ 主な機能

### 🔢 ウィルパワー可視化
- 現在の意思力レベルをリアルタイムで数値表示
- 日・週・月単位での意思力推移をグラフで確認
- 個人の意思力パターンを学習・分析

### 📋 タスク管理
- タスクごとに必要な意思力コストを設定
- 現在の意思力レベルに基づく最適なタスク提案
- 意思力消費の履歴とパターン分析

### 🎯 意思力最適化
- 重要なタスクへの意思力集中サポート
- 意思力回復のためのレコメンデーション
- 個人に最適化された意思力管理アドバイス

## 🚀 なぜ WillMeter なのか？

### 問題意識
現代社会では、無数の選択肢と誘惑が私たちの意思力を日々消耗させています。結果として、本当に大切なことや楽しみたいことに集中する力が残らないという問題があります。

### 解決アプローチ
WillMeter は意思力を「見える化」することで：
- 限りあるリソースとしての意思力を意識的に管理
- 重要度の高いタスクに意思力を優先配分
- 意思力の無駄遣いを減らし、本来の目標達成をサポート

### 期待される効果
- 📈 重要なタスクへの集中力向上
- 🎪 趣味や楽しみの時間の質向上
- 🔄 持続可能な生活習慣の構築
- 😌 意思決定疲れの軽減

## 🛠️ 技術スタック

- **フレームワーク**: SwiftUI
- **最小対応OS**: iOS 18.5+
- **開発環境**: Xcode 16.4+
- **アーキテクチャ**: DDD (Domain-Driven Design) + TDD (Test-Driven Development)
- **品質管理**: SwiftLint + Code Rabbit AI Review

## 🏗️ アーキテクチャ

本プロジェクトは **Clean Architecture + DDD** を採用し、4層構造でレイヤー分離を実現：

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

### 🎯 レイヤー責務の明確化

#### **Domain層** (ビジネスルールの中心)
- **WillPower**: 意思力エンティティ（Observer Pattern実装）
- **Task**: タスクエンティティ（ライフサイクル管理）
- **Repository Interface**: データアクセス抽象化

#### **Application層** (ビジネスフローの調整)
- **WillPowerUseCase**: 意思力の読み込み・保存フロー
- ドメインサービスとインフラ層の調整

#### **Infrastructure層** (技術的な詳細実装)
- **ObservableWillPower**: SwiftUI統合用ラッパー
- **ObservableTask**: TaskエンティティのUI統合
- **Repository実装**: InMemory/UserDefaults永続化

#### **Presentation層** (ユーザーインターフェース)
- **WillPowerViewModel**: UI特化のプレゼンテーションロジック
- **ContentView**: SwiftUI宣言的UI

### 🔧 技術的特徴

#### ObservableObject責務の適切な分離
```swift
// ❌ 従来（Domain層にObservableObject）
public class WillPower: ObservableObject {
    @Published var currentValue: Int
}

// ✅ 現在（Infrastructure層でラップ）
// Domain層: Pure Entity
public class WillPower {
    private(set) var currentValue: Int
    private var observers: [(WillPower) -> Void] = []
}

// Infrastructure層: SwiftUI統合
public class ObservableWillPower: ObservableObject {
    @Published private var willPower: WillPower
}
```

#### Observer Patternによるドメインイベント
- ドメインエンティティの変更を通知
- インフラ層がUI更新をハンドリング
- 依存方向の適切な制御

## 🧪 開発方針

### テスト駆動開発 (TDD)
- Red-Green-Refactor サイクルの徹底
- ドメインロジックの完全テストカバレッジ
- 継続的リファクタリングによる品質向上

### ドメイン駆動設計 (DDD)
- ユビキタス言語による共通理解
- 意思力管理ドメインの深いモデリング
- 境界づけられたコンテキストによる複雑性管理

### 品質保証
- **SwiftLint**: 静的解析による品質維持
- **Code Rabbit**: AI支援レビューの活用
- **客観的指標**: 測定可能な品質メトリクス

## 📊 開発状況

### 現在のフェーズ: ✅ Clean Architecture実装完了
- [x] プロジェクト初期設定
- [x] DDD + TDD 開発環境構築
- [x] Git/GitHub 管理開始
- [x] Clean Architecture 4層構造実装
- [x] ドメインモデル設計（WillPower, Task エンティティ）
- [x] 基本UI実装（Circle Progress Gauge）
- [x] データ永続化実装（Repository Pattern）
- [x] Infrastructure層分離（ObservableObject責務適正化）
- [x] 25個の包括的単体テスト実装

### 品質指標（達成済み）
- **テストカバレッジ**: 25個の単体テスト（Red-Green-Refactor）
- **SwiftLint違反**: 0件（100%準拠）
- **Code Rabbit評価**: AAA+（アーキテクチャ設計優秀評価）
- **アーキテクチャ違反**: 0件（Clean Architecture準拠）

## 🤝 開発方針

### AI支援開発
開発支援AIは**理系女子大学院生**のペルソナで：
- 論理的で体系的なアプローチ
- エビデンスベースの問題解決
- 最新研究動向の活用

### コードレビュー
- **Code Rabbit** による AI支援レビュー必須
- DDD原則の厳格な適用
- 客観的指標による品質評価

## 🔮 今後の展開

### Phase 1: コアMVP (Minimum Viable Product)
- 基本的な意思力カウンター機能
- シンプルなタスク管理
- データ永続化

### Phase 2: インテリジェント機能
- 意思力パターン学習
- 最適タスク提案
- 個人化されたアドバイス

### Phase 3: ソーシャル機能
- 意思力管理のベストプラクティス共有
- コミュニティ機能
- データドリブンな洞察提供

## 📞 貢献

このプロジェクトは、日々の生活をより良くしたいすべての人のために開発されています。バグ報告、機能提案、コード貢献など、あらゆる形での参加を歓迎します。

### 開発参加の前に
1. [CLAUDE.md](./CLAUDE.md) を必読
2. DDD + TDD 開発方針の理解
3. SwiftLint セットアップ
4. Code Rabbit レビュー設定

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

*「意思力を見える化して、本当に大切なことに集中する」*

**WillMeter** で、あなたの毎日をもっと意味のあるものに。