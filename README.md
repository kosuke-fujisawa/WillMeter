# WillMeter 🎯

> ウィルパワーを可視化して、本当にやりたいことに集中するための意思力管理アプリ

## 概要

**WillMeter** は、ウィルパワー（意思力）を数値として可視化し、日々のタスク決定をサポートする iOS アプリケーションです。限りある意思力を効果的に配分することで、本来自分がやりたかったことや楽しみたいことに集中できるようになり、より充実した日々を送ることを目的としています。

## ✨ 主な機能（現在実装済み）

### 🔢 ウィルパワー可視化
- 現在の意思力レベルを円形ゲージでリアルタイム表示
- 状態（最高／良好／低下／危険）に応じた色分けと一言アドバイス表示

### 🎛️ ウィルパワー操作
- ウィルパワーの消費・回復・リセット操作

### 🌐 多言語対応
- 日本語・英語・簡体字中国語の切り替え

> タスク管理、意思力推移のグラフ表示・履歴分析、パターン学習、個人化されたレコメンデーションは未実装です。実装状況は [📊 開発状況](#-開発状況) を、今後の計画は [🔮 今後の展開](#-今後の展開) を参照してください。

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
- **アーキテクチャ**: Simple First（軽量・シンプル優先） + TDD (Test-Driven Development)
- **品質管理**: SwiftLint + AI自動レビュー（[docs/ai-review.md](docs/ai-review.md)）

## 🏗️ アーキテクチャ

本プロジェクトは **Simple First** を設計方針とします。ドメインロジックを UI・永続化から分離しつつ、レイヤーや抽象化の一律強制はしません。判断の経緯は [ADR 0002](docs/adr/0002-adopt-simple-first-architecture.md) を参照してください。

```text
WillMeter/
├── WillMeterApp.swift        ← エントリポイント
├── ContentView.swift         ← メイン画面と依存の組み立て
├── Domain/                   ← WillPower（値と不変条件）、翻訳キー定義
├── Application/              ← WillPowerUseCase（読み込み・保存の窓口）
├── Infrastructure/           ← UserDefaults永続化、ローカライズ実装
└── Presentation/             ← WillPowerViewModel、テーマ、設定画面
```

データフローは `ContentView`（依存の組み立て）→ `WillPowerViewModel` → `WillPowerUseCase` → `WillPowerRepository`（UserDefaults実装）。ドメインの変更はオブザーバ経由で ViewModel が購読し、SwiftUI を再描画します（[ADR 0003](docs/adr/0003-simplify-ui-change-notifications.md)）。

設計上の主な決定は `docs/adr/` に記録しています。

- [ADR 0001](docs/adr/0001-willpower-no-daily-reset.md): ウィルパワーは暦日で自動リセットしない
- [ADR 0002](docs/adr/0002-adopt-simple-first-architecture.md): Simple First を既定の設計方針として採用
- [ADR 0003](docs/adr/0003-simplify-ui-change-notifications.md): UI変更通知を ViewModel へ集約

## 🧪 開発方針

### テスト駆動開発 (TDD)
- Red-Green-Refactor サイクルで新しい振る舞いとバグ修正を進める
- ドメインロジックは UI・永続化から独立してテストする

### 品質保証
- **SwiftLint**: 静的解析による品質維持
- **AI自動レビュー**: PRごとに自動レビューを実行（[docs/ai-review.md](docs/ai-review.md)）
- **CI**: push/PR ごとに SwiftLint + Unit Test を実行（`.github/workflows/ci.yml`）

## 📊 開発状況

### 現在のフェーズ: ユーザーテスト（TestFlight配布）に向けた仕上げ中

TestFlightへのArchive・アップロードとバージョン運用は、[TestFlight配布手順](docs/testflight.md)を参照してください。アップロード時のビルド番号はXcodeが自動管理します。
クラッシュ発生時の確認方法と検証手順は、[クラッシュレポート運用手順](docs/crash-reporting.md)を参照してください。
- [x] ウィルパワーの円形ゲージ表示、消費/回復/リセット操作
- [x] データ永続化（アプリ再起動でウィルパワーの値を保持）
- [x] 多言語対応（日本語・英語・簡体字中国語）
- [x] オンボーディング画面
- [x] 単体テスト・UIテストと CI（SwiftLint + Unit Test）
- [ ] タスク管理機能
- [ ] 意思力推移のグラフ表示・履歴分析

ユーザーテスト実施に向けた残タスクは [GitHub Issues](https://github.com/kosuke-fujisawa/WillMeter/issues) で管理しています。

## 🔮 今後の展開

### Phase 1: コアMVP (Minimum Viable Product)
- 基本的な意思力カウンター機能と永続化（実装済み）
- シンプルなタスク管理画面
- 意思力推移のグラフ表示・履歴分析

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
2. Simple First + TDD 開発方針の理解（[ADR 0002](docs/adr/0002-adopt-simple-first-architecture.md)）
3. SwiftLint セットアップ

## 📄 ライセンス

このプロジェクトは **[Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/)** の下でライセンスされています。

### ✅ 許可されること

- **非営利目的での自由な利用**: 複製、配布、改変が可能
- **改変作品の作成**: リミックス、変換、派生作品の作成
- **あらゆる媒体・形式での共有**: 制限なし

### ⛔ 制限事項

- **商用利用の禁止**: 営利目的での使用は許可されていません
- **適切なクレジット表示**: 作者名、ライセンスへのリンク、変更点の明示が必要
  例: `© 2025 kosuke-fujisawa — CC BY-NC 4.0`

詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

「意思力を見える化して、本当に大切なことに集中する」

**WillMeter** で、あなたの毎日をもっと意味のあるものに。
