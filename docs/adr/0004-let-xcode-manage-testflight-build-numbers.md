# 0004. TestFlightのビルド番号はアップロード時にXcodeへ自動管理させる

- 日付: 2026-07-13
- 状態: 採用

## 背景

TestFlightへ同じアプリバージョンを複数回アップロードするには、各ビルドを一意に識別できるビルド番号が必要である。従来は`CURRENT_PROJECT_VERSION = 1`が固定され、アップロード前に手動編集する必要があった。

現時点では署名情報を扱う配布用GitHub ActionsやXcode Cloudを導入しておらず、開発者のMacに設定されたXcodeアカウントから配布する運用である。

## 選択肢

1. Xcodeの`manageAppVersionAndBuildNumber`を有効にし、App Store Connectへのアップロード時に自動採番する
2. `agvtool`で`CURRENT_PROJECT_VERSION`を更新し、変更を毎回コミットする
3. GitHub Actionsのrun numberを使い、署名・アップロードまでCIへ移行する
4. Gitコミット数や日時からビルド番号を生成する

## 採用案

`scripts/upload-testflight.sh`からApp Store Connectへアップロードし、ExportOptionsの`manageAppVersionAndBuildNumber`を有効にする。Xcodeにアップロード対象Archiveのビルド番号を自動管理させる。

マーケティングバージョンは`MAJOR.MINOR.PATCH`とし、次の規則でリリース単位に更新する。

- `MAJOR`: 互換性を保てない大きな変更
- `MINOR`: 互換性を保つ機能追加
- `PATCH`: 互換性を保つ不具合修正

同じマーケティングバージョン内のTestFlight再配布では、マーケティングバージョンを変更しない。

## 採用理由

- AppleとXcodeが提供する標準機能だけで完結し、外部依存を増やさない
- `project.pbxproj`の機械的な番号更新と、そのためだけのコミットを避けられる
- 現在のローカルXcodeによる配布運用を維持できる
- 将来CI配布へ移行する場合も、ExportOptionsと運用規則を再利用できる

## 欠点・リスク

- 実際に採番された値はApp Store Connectまたは配布ログで確認する必要がある
- Xcodeへ適切なApple Accountが登録され、対象Teamの署名権限が必要である
- 完全な無人配布ではなく、開発者のMac環境に依存する
- Xcodeの自動管理仕様が変更された場合は運用を見直す必要がある

## 再評価条件

- TestFlight配布をGitHub ActionsまたはXcode Cloudへ移行するとき
- 複数の開発者・複数のMacから並行して配布する必要が生じたとき
- Xcodeのビルド番号自動管理で衝突または採番失敗が発生したとき

## 影響範囲

- `Config/TestFlightExportOptions.plist`
- `scripts/upload-testflight.sh`
- TestFlight配布手順
- `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`の運用

## 参考資料

- [Apple: Distributing your app for beta testing and releases](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Apple: Preparing your app for distribution](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution)
- [Apple: Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
