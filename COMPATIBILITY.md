# OS・ライブラリアップデート対応指針

## 概要
WillMeterプロジェクトにおけるOS・ライブラリアップデートの影響を最小化するための設計指針と対応戦略。

## 現在の互換性設定

### iOS対応バージョン
- **最小対応**: iOS 18.5+
- **推奨戦略**: 現行-1世代（約2年間）のサポート
- **テスト対象**: iOS 18.5, iOS 19.0（リリース時）

### Swift・Xcode
- **Swift Version**: 5.0
- **Xcode**: 16.4+
- **Language Mode**: Swift 5

## 依存関係分析

### 外部依存関係（ゼロ依存戦略）
✅ **現状**: 外部ライブラリの依存なし
- Swift Package Manager未使用
- CocoaPods未使用
- Carthage未使用

### システムフレームワーク依存
- **Foundation**: UUID, Date, TimeInterval（ドメイン必須）
- **SwiftUI**: UI層のみ（Infrastructure/Presentation層）
- **Combine**: ViewModelでの状態管理（Presentation層）
- **XCTest**: テスト専用

## Clean Architecture による影響局所化

### Domain層（影響ゼロ）
```
WillMeter/Domain/
├── Entities/
│   ├── WillPower.swift     ← Foundation（UUID, Date）のみ
│   └── Task.swift          ← Foundation（UUID, Date）のみ
└── Repositories/
    ├── WillPowerRepository.swift  ← Protocol定義のみ
    └── TaskRepository.swift       ← Protocol定義のみ
```
- **外部依存**: Foundation基本型のみ
- **OS依存**: なし
- **変更影響**: 最小限

### Application層（影響最小）
```
WillMeter/Application/
└── UseCases/
    └── WillPowerUseCase.swift  ← Foundation, Domain依存のみ
```
- **外部依存**: Domain層経由のみ
- **OS依存**: なし

### Infrastructure層（影響局所化）
```
WillMeter/Infrastructure/
├── Observables/           ← SwiftUI依存（局所化済み）
└── Repositories/          ← 永続化実装（将来的影響あり）
```
- **OS依存**: SwiftUI, UserDefaults等
- **対策**: Adapter Pattern適用済み

### Presentation層（影響範囲明確）
```
WillMeter/Presentation/
└── ViewModels/
    └── WillPowerViewModel.swift  ← SwiftUI, Combine依存
```
- **OS依存**: SwiftUI, Combine
- **対策**: ViewModelで抽象化

## アップデート対応ストラテジー

### 1. Deployment Target管理
- **現在**: iOS 18.5+
- **更新方針**: 年1回、iOS 2世代サポート
- **判断基準**: App Store統計でのシェア85%以上

### 2. Swift Language Version
- **現在**: Swift 5.0
- **更新方針**: LTS版優先、安定性重視
- **移行タイミング**: 新機能が必要な時のみ

### 3. SwiftUI互換性
- **対策**: `@available` アノテーション活用
- **fallback**: 古いAPIでの代替実装
- **テスト**: 複数iOS版での動作確認

### 4. 非推奨API対応
```swift
// 推奨パターン: @available での分岐
@available(iOS 19.0, *)
private func newAPIMethod() {
    // 新しいAPI実装
}

@available(iOS, deprecated: 19.0)
private func legacyAPIMethod() {
    // 従来API実装
}
```

## 互換性テスト戦略

### テスト環境
- **Simulator**: iOS 18.5, 19.0
- **実機**: 可能な限り実デバイスでの検証
- **CI/CD**: GitHub Actions での自動テスト

### テストケース
1. **基本機能テスト**: 全iOS版での動作確認
2. **UI互換性テスト**: SwiftUIレイアウト検証
3. **永続化テスト**: UserDefaults動作確認
4. **パフォーマンステスト**: メモリ・CPU使用量

## マイグレーション指針

### アップデート手順
1. **事前調査**: リリースノート確認
2. **影響分析**: Breaking Changes特定
3. **テスト実行**: 既存テストスイートの実行
4. **段階的適用**: layer-by-layer での更新
5. **回帰テスト**: 全機能の動作確認

### ロールバック戦略
- **Git分岐**: feature_ios_xx ブランチでの作業
- **設定保存**: 既存プロジェクト設定のバックアップ
- **段階的マージ**: PRレビューでの慎重な統合

## リスク軽減措置

### 高リスク要素
1. **SwiftUI変更**: レイアウト・API仕様変更
2. **Xcode更新**: ビルド設定・署名変更
3. **iOS更新**: システム動作・権限変更

### 対応策
1. **早期検証**: Beta版での事前テスト
2. **段階的移行**: 機能単位での更新
3. **フォールバック**: 旧実装の並行保持
4. **ドキュメント**: 変更内容の詳細記録

## 品質保証

### 自動テスト
- **単体テスト**: 25個のテストケース維持
- **統合テスト**: ViewModel-Domain連携確認
- **UIテスト**: 基本操作の自動化

### 手動テスト
- **多様なデバイス**: iPhone/iPad各世代
- **OS組み合わせ**: サポート範囲全体
- **エッジケース**: 境界値・異常系

## 継続的改善

### 四半期レビュー
- **依存関係監査**: セキュリティ・互換性確認
- **パフォーマンス測定**: ベンチマーク実行
- **技術負債評価**: リファクタリング優先度

### 年次戦略見直し
- **Deployment Target更新**: サポート範囲調整
- **アーキテクチャ進化**: 新パターン適用検討
- **ツール更新**: 開発環境の最適化

---

**最終更新**: 2025年7月（issue#3対応）
**次回見直し**: 2025年10月（四半期レビュー）