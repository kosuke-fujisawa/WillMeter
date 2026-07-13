# Issue #39 設定確認・動作テスト記録

## 確認概要

- タスク: ビルド番号・バージョニングの自動化
- 確認日: 2026-07-13

## 設定確認結果

- [x] ExportOptions plistが正しいplist形式である
- [x] 配布方法が`app-store-connect`である
- [x] 配布先が`upload`である
- [x] `manageAppVersionAndBuildNumber`が有効である
- [x] 自動署名が指定されている
- [x] dSYMアップロードが有効である
- [x] DerivedDataが`/Volumes/T7 Shield/DerivedData`へ保存される

## 動作テスト結果

- [x] Shell構文チェック成功
- [x] `--dry-run`でArchive・Uploadコマンドを確認
- [x] Developer Team未指定時の異常系テスト成功
- [x] スクリプトテスト成功
- [x] SwiftLint成功
- [x] 全Unit Test成功
- [x] iPhone 16 Simulator向けBuild成功
- [x] 署名なしRelease Build成功
- [ ] 署名付きArchive成功
- [ ] App Store Connectへのアップロード成功
- [ ] 同一マーケティングバージョンで2回アップロードし、異なるビルド番号が採番されることを確認

## 未検証項目の理由

実行環境のKeychainに有効なコード署名Identityがなく、Apple Developer Teamもプロジェクトへ固定していない。署名・アカウント情報をリポジトリへ追加せず、権限を持つMacで最終確認する。

## 判定

設定とローカルで検証可能な経路は正常。Issue #39の受け入れ条件を完全に満たすには、署名環境での複数回アップロード確認が残る。
