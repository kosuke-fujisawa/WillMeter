# Issue #40 設定作業実行記録

## 作業概要

- タスク: クラッシュレポート収集の導入
- 実行日: 2026-07-13
- 根拠: GitHub Issue #40、AppleのTestFlightクラッシュレポート仕様

## 参照文書

- `CLAUDE.md`
- `docs/adr/0005-use-apple-crash-reports.md`
- Apple Developer Documentation: Acquiring crash reports and diagnostic logs
- App Store Connect Help: View tester feedback

## 実行した作業

1. Apple標準クラッシュレポートを採用し、外部SDKを追加しない判断をADR 0005へ記録
2. `--enable-crash-test`をTestFlightアップロードスクリプトへ追加
3. `CRASH_REPORT_TESTING`有効時だけ表示される検証UIを追加
4. 意図的クラッシュ前に確認ダイアログを表示
5. 通常ビルドへ検証UIが混入しないことをスクリプトテストとRelease Buildで確認
6. 配布、クラッシュ発生、App Store Connect / Xcode Organizerでの確認手順を文書化

## 依存関係・設定

- 新しい外部SDK: なし
- 新しいサービスアカウント・秘密情報: なし
- 既存のExportOptions: `uploadSymbols = true`を継続利用

## 遭遇した制約

- ローカルKeychainに有効なコード署名Identityがないため、検証用TestFlightビルドのアップロードは実行していない
- 実機クラッシュとApple側レポートの確認には、署名環境とTestFlightテスターが必要

## 次のステップ

- 署名環境で検証用ビルドをTestFlightへアップロードする
- テスト端末で意図的クラッシュを発生させ、Apple側のレポートを確認する
- 検証後に通常ビルドへ差し替える
