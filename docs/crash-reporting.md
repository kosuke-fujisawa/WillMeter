# クラッシュレポート運用手順

## 収集方針

WillMeterは、TestFlightとAppleプラットフォームが提供する標準クラッシュレポートを利用します。Firebase CrashlyticsやSentryなどの外部SDKは導入しません。判断理由は[ADR 0005](adr/0005-use-apple-crash-reports.md)を参照してください。

TestFlightユーザーのクラッシュレポートはAppleへ自動共有されます。アップロード設定では`uploadSymbols`を有効にし、シンボル情報を含めます。配布したArchiveは、レポートの調査が終わるまで保持してください。

## 検証用ビルドをアップロードする

有効なApple Developer Teamと署名環境で、次を実行します。

```bash
DEVELOPMENT_TEAM=XXXXXXXXXX scripts/upload-testflight.sh --enable-crash-test
```

このオプションを付けたビルドだけ、言語設定画面に「クラッシュレポートを検証」ボタンが表示されます。通常ビルドには表示されません。

## テスト端末でクラッシュを発生させる

1. App Store Connectで検証用ビルドをテスターグループへ追加する
2. テスト端末のTestFlightから検証用ビルドをインストールする
3. WillMeterを起動し、右上の地球アイコンから言語設定を開く
4. 「クラッシュレポートを検証」をタップする
5. 確認ダイアログで「クラッシュさせる」をタップする
6. アプリが終了した時刻、ビルド番号、端末、OSバージョンを記録する
7. TestFlightからクラッシュに関するフィードバック送信を求められた場合は、検証であることが分かるコメントを添えて送信する

この操作はデータ破損を目的としませんが、アプリを意図的に異常終了させます。検証用ビルドでのみ実行してください。

## レポートを確認する

次のいずれかで、記録したビルド番号と時刻に対応するクラッシュを確認します。TestFlightのクラッシュレポートはXcode Organizerへ自動共有されます。App Store ConnectのFeedbackに表示するには、テスターからのフィードバック送信が必要になる場合があります。

### App Store Connect

1. AppsからWillMeterを選択する
2. TestFlightタブを開く
3. FeedbackのCrashesを開く
4. ビルド、OS、端末で絞り込む
5. クラッシュ詳細またはダウンロードしたレポートで、`CrashReportTestSection`または検証用メッセージへ到達するスタックを確認する

### Xcode Organizer

1. XcodeのWindowからOrganizerを開く
2. CrashesでWillMeterと対象バージョンを選択する
3. 対象クラッシュがシンボル化され、関数名と行番号を確認できることを確認する

## 検証後

1. `--enable-crash-test`を付けずに通常ビルドをアップロードする
2. 通常ビルドをテスターグループへ追加する
3. 検証用ビルドをテスターの配布対象から外す
4. Issue #40へ、確認したビルド番号・端末・OS・確認場所を記録する

## レポートが見つからない場合

- App Store Connectへの反映を待って再確認する
- 対象ビルドにdSYMが含まれ、アップロードされているか確認する
- Xcode Organizerへ正しいApple Accountでログインしているか確認する
- テスト端末の設定からAnalytics Dataを開き、WillMeterで始まるクラッシュログを直接共有する

## 参考資料

- [Apple: Acquiring crash reports and diagnostic logs](https://developer.apple.com/documentation/xcode/acquiring-crash-reports-and-diagnostic-logs)
- [Apple: View tester feedback](https://developer.apple.com/help/app-store-connect/test-a-beta-version/view-tester-feedback/)
- [Apple: Diagnosing issues using crash reports and device logs](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports-and-device-logs)
