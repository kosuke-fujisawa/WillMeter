# Issue #40 設定作業実行記録

## 作業概要

- タスク: クラッシュレポート収集の導入
- 実行日: 2026-07-13、2026-07-19〜2026-07-20
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
7. Apple Developer Programの配布用Teamで署名証明書とProvisioning Profileを作成
8. App Store ConnectへWillMeter（Bundle ID: `mhlyc.WillMeter`）を登録
9. `CRASH_REPORT_TESTING`有効のTestFlightビルド`1.0 (1)`をアップロード
10. iPhone SE（第3世代）で意図的クラッシュを実行し、TestFlightフィードバックを送信
11. 端末のIPSとXcode Organizerの両方でシンボル化されたクラッシュを確認
12. 検証UIを含まない通常ビルド`1.0 (2)`を作成し、TestFlightへアップロード

## 依存関係・設定

- 新しい外部SDK: なし
- 新しいサービスアカウント・リポジトリ内の秘密情報: なし
- 既存のExportOptions: `uploadSymbols = true`を継続利用
- 署名証明書と秘密鍵: ローカルKeychainで管理し、リポジトリへ保存しない
- 配布用Archive: 調査が完了するまでローカル一時領域で保持

## 遭遇した制約と対応

- Apple Developer Program加入前はPersonal Teamのみだったため、加入後に配布用TeamをXcodeへ反映した
- TestFlight配布用の署名IdentityとProvisioning Profileがなかったため、Xcodeで証明書と署名設定を準備した
- 実機検証の準備として、Developer Modeを有効にしたテスト端末をTeamへ登録した（TestFlight配布自体の必須手順ではない）
- App Store Connectにアプリレコードがなかったため、Bundle ID `mhlyc.WillMeter`でWillMeterを登録した
- 検証ビルドのアップロード後、Apple側の処理完了を待って内部テスターへ配布した

## 検証後のクリーンアップ

- [x] 検証UIを含まない通常ビルド`1.0 (2)`へ更新
- [x] 実機の言語設定画面にクラッシュ検証導線が表示されないことを確認
- [x] 検証用ビルド`1.0 (1)`を期限切れにして新規インストールを停止
