# Issue #39 設定作業実行記録

## 作業概要

- タスク: ビルド番号・バージョニングの自動化
- 実行日: 2026-07-13
- 根拠: GitHub Issue #39、AppleのApp Store Connect配布仕様

## 参照文書

- `CLAUDE.md`
- `docs/adr/0004-let-xcode-manage-testflight-build-numbers.md`
- Apple Developer Documentation: Distributing your app for beta testing and releases
- Apple Developer Documentation: Preparing your app for distribution
- App Store Connect Help: Upload builds

## 実行した作業

1. `Config/TestFlightExportOptions.plist`を追加
   - App Store Connectへの直接アップロードを指定
   - Xcodeのビルド番号自動管理を有効化
   - 自動署名とdSYMアップロードを指定
2. `scripts/upload-testflight.sh`を追加
   - Release Archiveを外付けDerivedDataへ生成
   - App Store Connectへのアップロードを実行
   - `--dry-run`とArchive保存先指定に対応
   - Developer Team未指定時はアップロード前に停止
3. `scripts/tests/upload-testflight-test.sh`を追加
   - ExportOptionsとコマンド構成を自動検証
   - Developer Team未指定の異常系を検証
4. `docs/testflight.md`とREADMEへ配布手順を追加
5. ADR 0004へ採番方式とマーケティングバージョン規則を記録

## 遭遇した制約

- ローカルKeychainに有効なコード署名Identityがないため、実際のApp Store Connectアップロードは実行していない
- 署名付きArchiveとアップロードには、Xcodeへ登録済みのApple Account、Developer Team、配布権限が必要

## 次のステップ

- 自動テスト、plist検証、署名なしRelease Buildを実行する
- 署名環境でTestFlightへ2回以上アップロードし、自動採番されたビルド番号を確認する
