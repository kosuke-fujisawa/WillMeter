# TestFlight配布手順

## バージョン方針

- マーケティングバージョンは`MAJOR.MINOR.PATCH`で管理する
- 同じバージョンのTestFlight再配布ではマーケティングバージョンを変更しない
- 新しいApp Storeバージョンを作るときだけ、変更内容に応じて`MAJOR` / `MINOR` / `PATCH`を更新する
- ビルド番号はApp Store Connectへのアップロード時にXcodeが自動管理する

判断理由と再評価条件は[ADR 0004](adr/0004-let-xcode-manage-testflight-build-numbers.md)を参照してください。

## 前提条件

1. XcodeのAccountsに、App Store Connectへ接続できるApple Accountが登録されている
2. Bundle ID `mhlyc.WillMeter`のAppがApp Store Connectに登録されている
3. 配布権限を持つApple Developer Team IDを確認できる
4. Xcodeのライセンス同意と必要な証明書・Provisioning Profileの取得が完了している

## コマンド確認

実際にArchiveやアップロードを行わず、実行予定のコマンドを確認します。

```bash
DEVELOPMENT_TEAM=XXXXXXXXXX scripts/upload-testflight.sh --dry-run
```

## TestFlightへアップロード

```bash
DEVELOPMENT_TEAM=XXXXXXXXXX scripts/upload-testflight.sh
```

Archiveは一時ディレクトリへ作成されます。保存先を指定する場合は次のように実行します。

```bash
DEVELOPMENT_TEAM=XXXXXXXXXX scripts/upload-testflight.sh \
  --archive-path /path/to/WillMeter.xcarchive
```

スクリプトは次の処理を順に実行します。

1. Release構成で署名付きArchiveを作成する
2. Xcodeのビルド番号自動管理を有効にする
3. ArchiveをApp Store Connectへアップロードする

アップロード後は、App Store ConnectのTestFlight画面で処理状態と実際のビルド番号を確認してください。Apple側の処理が完了したビルドは`Complete`として表示されます。

## エラー時

- `DEVELOPMENT_TEAM`エラー: Apple Developer Team IDを指定する
- 署名エラー: XcodeのAccounts、証明書、Provisioning Profile、Bundle IDを確認する
- 認証エラー: XcodeでApple Accountへ再ログインする
- アップロード失敗: App Store ConnectのBuild Uploadsでエラー詳細を確認する

Apple側で処理が`Failed`になった場合は、同じビルド番号を再利用できる場合があります。Xcodeの自動管理に任せ、プロジェクトファイルを手動編集しないでください。
