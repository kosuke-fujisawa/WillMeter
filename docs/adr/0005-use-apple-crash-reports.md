# 0005. クラッシュレポート収集にはApple標準機能を使う

- 日付: 2026-07-13
- 状態: 採用

## 背景

TestFlightテスターが遭遇したクラッシュを開発者が確認できる経路が文書化・検証されておらず、申告だけでは原因調査が難しい。クラッシュ収集手段としてApple標準機能、Firebase Crashlytics、Sentryを検討する必要がある。

## 選択肢

1. TestFlightとXcode Organizer / App Store ConnectのApple標準クラッシュレポートを使う
2. Firebase Crashlytics SDKを導入する
3. Sentry SDKを導入する

## 採用案

TestFlightが自動収集するApple標準クラッシュレポートを使う。検証時だけ有効になるコンパイル条件`CRASH_REPORT_TESTING`を用意し、専用TestFlightビルドから意図的なクラッシュを発生させる。

## 採用理由

- TestFlightユーザーのクラッシュレポートはAppleの仕組みで自動共有される
- 外部SDK、サービスアカウント、設定ファイルを追加せずに目的を満たせる
- OSが生成した完全なクラッシュレポートとdSYMによるシンボル情報をXcodeで扱える
- 通常ビルドにはクラッシュ検証UIを含めず、誤操作のリスクを抑えられる

## 欠点・リスク

- レポートが表示されるまで時間がかかる場合がある
- TestFlightへアップロードできる署名環境と実機テスターが必要である
- アプリ独自のイベント履歴やユーザー属性など、外部サービスの追加情報は得られない
- シンボル情報を含めてアップロードし、配布Archiveを保持する必要がある

## 再評価条件

- Apple標準レポートだけでは原因特定に必要な情報が不足したとき
- クラッシュ通知の即時性や、イベント履歴との相関分析が必要になったとき
- AndroidなどApple以外のプラットフォームへ展開するとき

## 影響範囲

- TestFlightアップロードスクリプト
- クラッシュ検証専用UI
- TestFlight運用手順
- クラッシュレポート確認手順

## 参考資料

- [Apple: Acquiring crash reports and diagnostic logs](https://developer.apple.com/documentation/xcode/acquiring-crash-reports-and-diagnostic-logs)
- [Apple: View tester feedback](https://developer.apple.com/help/app-store-connect/test-a-beta-version/view-tester-feedback/)
- [Apple: Diagnosing issues using crash reports and device logs](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports-and-device-logs)
