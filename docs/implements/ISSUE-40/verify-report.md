# Issue #40 設定確認・動作テスト記録

## 確認概要

- タスク: クラッシュレポート収集の導入
- 確認日: 2026-07-13、2026-07-20

## 設定確認結果

- [x] Apple標準クラッシュレポートの採用方針をADRへ記録
- [x] ExportOptionsでdSYMアップロードが有効
- [x] 通常Archiveに`CRASH_REPORT_TESTING`が含まれない
- [x] 検証用Archiveに`CRASH_REPORT_TESTING`が含まれる
- [x] 検証UIがコンパイル条件で隔離されている
- [x] 意図的クラッシュ前に確認ダイアログがある
- [x] 外部SDK・秘密情報を追加していない

## 動作テスト結果

- [x] スクリプトテスト成功
- [x] Shell構文チェック成功
- [x] 検証フラグ付きRelease Simulator Build成功
- [x] 検証フラグ付きバイナリに検証導線が含まれることを確認
- [x] 検証UIの表示、確認ダイアログ、キャンセル操作のUI Test成功
- [x] 通常Release Simulator Build成功
- [x] 通常バイナリに検証導線が含まれないことを確認
- [x] 署名付きArchive成功
- [x] 検証用TestFlightビルド`1.0 (1)`のアップロード成功
- [x] iPhone SE（第3世代）/ iOS 26.5.2で意図的クラッシュを実行
- [x] Xcode OrganizerでTestFlightのシンボル化されたレポートを確認
- [x] 検証後に通常ビルド`1.0 (2)`へ差し替え

## 実機検証の証拠

- クラッシュ日時: 2026-07-20 10:55:48 JST
- アプリ: WillMeter `1.0 (1)` / Bundle ID `mhlyc.WillMeter`
- 端末: iPhone SE（第3世代）/ iOS 26.5.2 (23F84)
- 端末ログ: `WillMeter-2026-07-20-105548.ips`
- 例外: `EXC_BREAKPOINT` / `SIGTRAP`
- Incident ID: `775EC423-8452-4EBD-AADC-DA8FFF6B5FD3`
- dSYM UUID: `B7DEC83B-16BB-3FFC-B263-C8133D7CA624`
- シンボル化結果: `closure #1 in closure #2 in CrashReportTestSection.body.getter`
- Apple側確認場所: Xcode Organizer > Crashes
- Distribution表示: TestFlight
- TestFlight Feedback表示: あり

## 検証後のクリーンアップ

- 通常Archiveのバイナリに`CrashReportTestSection`と検証文言が含まれないことを確認した
- TestFlightから通常ビルド`1.0 (2)`を実機へインストールした
- 実機の言語設定画面にクラッシュ検証導線が表示されないことを確認した
- 検証用ビルド`1.0 (1)`を期限切れにした

## 判定

テスト端末で発生させたクラッシュがApple側へ収集され、Xcode OrganizerでTestFlightレポートとしてシンボル化されることを確認した。通常ビルドへの差し替えと検証ビルドの期限切れも完了しており、Issue #40の受け入れ条件と運用上のクリーンアップを完了した。
