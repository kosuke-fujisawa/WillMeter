# CLAUDE.md

このファイルは、このリポジトリで開発支援AIが作業する際のガイダンスです。

## プロジェクト概要

WillMeter は、ウィルパワー（意思力）を可視化・操作する SwiftUI ベースの iOS アプリです。

## 設計方針

このリポジトリは、共通の設計原則である **Simple First（軽量・シンプル優先）** に従います。以前掲げていた「Clean Architecture + DDD の4層構造を常に強制する」方針は採用しません。判断の経緯は [ADR 0002](docs/adr/0002-adopt-simple-first-architecture.md) を参照してください。

優先順位は次のとおりです。

1. シンプルさ・理解しやすさ
2. テスト容易性
3. 必要になった時点での拡張性

### 守ること

- ドメインロジックを SwiftUI View へ置かず、UI・永続化などの I/O から分離する
- ウィルパワーなどのドメイン用語を型名・関数名へ反映する
- 範囲や不変条件を持つ値には、効果が明確な場合に Value Object を使う
- 変更理由が異なるコードを、小さな責務単位で分ける
- 公開APIと内部実装を区別する
- 新しい振る舞いとバグ修正は TDD の Red-Green-Refactor で進める

### 強制しないこと

- Domain / Application / Infrastructure / Presentation の形式的な4層分割
- Entity / Repository / Service / UseCase など、DDDパターンの一律導入
- 実装が1つしかなく、テストや差し替えにも不要な protocol
- 将来の拡張だけを理由にした抽象化、汎用ラッパー、ドメインイベント
- 小規模な変更に対する境界づけられたコンテキストや集約の先行設計

既存の4層ディレクトリや Repository protocol は直ちに撤去しません。既存コードを変更するときに、責務分離とテスト容易性を維持しながら、変更範囲内で単純化できるかを判断します。大規模な構造変更は別のADRで決定します。

## 開発手順

1. 既存テストと変更対象の依存関係を確認する
2. 期待する振る舞いをテストで表現し、失敗を確認する（Red）
3. テストを通す最小限の実装を行う（Green）
4. 重複や読みにくさを解消する（Refactor）
5. 変更範囲に応じて SwiftLint、Unit Test、Build を実行する

テストのために依存を差し替える必要が生じた場合は protocol の導入を検討できます。ただし、具体型やクロージャで十分なら、より単純な方法を優先します。

## コミュニケーション

- ユーザーへの応答は日本語を優先する
- コードコメントと技術文書は日本語を優先する
- コメントは「何をしているか」ではなく、コードから読み取れない理由や制約を書く

## 開発コマンド

起動ディスクの空き容量逼迫を避けるため、DerivedDataは外付けドライブ(`/Volumes/T7 Shield/DerivedData`)に保存する運用です(Xcode本体は `defaults write com.apple.dt.Xcode IDECustomDerivedDataLocation` で設定済み)。`xcodebuild` をCLIから直接実行する場合は `-derivedDataPath` を明示してください。

```bash
# 静的解析
swiftlint

# Unit Test
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath "/Volumes/T7 Shield/DerivedData" \
  test -only-testing:WillMeterTests

# UI Test
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath "/Volumes/T7 Shield/DerivedData" \
  test -only-testing:WillMeterUITests

# Build
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath "/Volumes/T7 Shield/DerivedData" build
```

利用可能なシミュレーター名が異なる場合は `xcrun simctl list devices available` で確認し、destination を調整してください。

## 品質基準

- SwiftLint の新規違反を増やさない
- 変更した振る舞いを自動テストで保証する
- ドメインロジックを UI・永続化フレームワークから独立してテストできる状態に保つ
- 未コミットの既存差分や無関係なファイルを変更しない
- 数値目標や「達成済み」の記載は、CIなどで検証可能な根拠がある場合に限る

## 技術要件

- Xcode 16.4 以上
- iOS 18.5 以上
- SwiftUI / XCTest / SwiftLint
