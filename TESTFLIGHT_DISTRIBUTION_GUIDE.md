# TestFlight配布ガイド

## 概要
ユーザーテストの実施にはTestFlightでのビルド配布が前提となる。本ドキュメントはArchive〜TestFlightアップロード〜テスター配布までの手順を、属人化を避けるために明文化したものである。

現時点では自動化（fastlane等）は導入しておらず、Xcode/App Store Connectの標準機能を使った手動手順を対象とする。自動化の要否は、この手順を数回運用してみてから判断する。

## 前提条件

- [ ] [Apple Developer Program](https://developer.apple.com/programs/) に登録済みのApple IDを保有していること（個人または組織アカウント）
- [ ] Xcodeで対象のApple IDがサインイン済みであること（Xcode > Settings > Accounts）
- [ ] App Store Connect（https://appstoreconnect.apple.com）でアプリ「WillMeter」が登録済みであること
  - 未登録の場合は「マイApp」→「+」→「新規App」から、Bundle ID `mhlyc.WillMeter` を選択して作成する
- [ ] Xcodeプロジェクトの Signing & Capabilities で、Team（開発チーム）が選択されていること
  - `WillMeter.xcodeproj` を開き、WillMeterターゲット → Signing & Capabilities タブ → Team に該当のApple Developerアカウントのチームを選択する
  - 本リポジトリの `project.pbxproj` には `DEVELOPMENT_TEAM` が含まれていない（Automatic signingでローカルのXcode設定に委ねている）ため、初回は各自のマシンでこの設定が必要

## 手順

### 1. バージョン番号の確認・更新

`WillMeter.xcodeproj` の Build Settings、またはターゲットの General タブで以下を確認する。

- **Version**（`MARKETING_VERSION`）: ユーザーに見えるバージョン番号（例: `1.0`）。機能追加・大きな変更時にインクリメントする
- **Build**（`CURRENT_PROJECT_VERSION`）: TestFlightへのアップロードごとに一意にする必要がある整数値。**同じVersion+Buildの組み合わせは再アップロードできない**ため、前回アップロード時より必ず増やす

現状はビルド番号の自動採番の仕組みがないため、アップロード前に手動でインクリメントすること（自動化はIssue化検討中）。

### 2. ビルド設定の確認

- [ ] スキームが `WillMeter`（Debugではなく配布用のRelease相当）になっていること
- [ ] 実行先（デスティネーション）が **Any iOS Device (arm64)** になっていること（シミュレータが選択されているとArchiveメニューが有効化されない）

### 3. Archiveの作成

1. Xcodeで `WillMeter.xcodeproj` を開く
2. メニューバー → **Product → Archive** を実行
3. ビルドが完了すると自動的に **Organizer**（Window > Organizer からも開ける）が開き、作成したArchiveが一覧に表示される

ビルドエラーになる場合は、先に以下を実行してローカルで問題がないことを確認する。
```bash
xcodebuild -project WillMeter.xcodeproj -scheme WillMeter -destination 'generic/platform=iOS' archive -archivePath /tmp/WillMeter.xcarchive
```

### 4. App Store Connectへのアップロード

1. Organizerで対象のArchiveを選択し、**Distribute App** をクリック
2. 配布方法として **App Store Connect** を選択 → Next
3. **Upload** を選択（Exportではなく、直接アップロードする方を選ぶ）→ Next
4. 署名は基本 **Automatically manage signing** のまま進める
5. 内容を確認し、**Upload** を実行
6. アップロードが完了すると「Upload Successful」の表示が出る。この時点ではTestFlightにはまだ表示されない（Apple側の処理待ち）

### 5. App Store Connect側の処理待ち・ビルド公開

1. [App Store Connect](https://appstoreconnect.apple.com) → 対象アプリ → **TestFlight** タブを開く
2. アップロードしたビルドが「処理中」と表示される（数分〜30分程度かかることがある）
3. 処理が完了すると「テストの準備ができました」等の状態になる
4. 初回ビルドのみ、輸出コンプライアンス（暗号化使用の有無）の質問に回答する必要がある場合がある（WillMeterは標準的なHTTPS通信程度のため、通常は「いいえ」または該当なしで問題ない）

### 6. テスターへの配布

#### 内部テスター（App Store Connectのチームメンバー、最大100名、審査不要・即時配布）
1. TestFlightタブ → **内部テスト** → グループを作成（初回のみ）
2. テスターのApple IDのメールアドレスを追加
3. 対象ビルドをそのグループに割り当てる → 自動的に通知が送られる

#### 外部テスター（一般ユーザー、最大10,000名、初回はApple審査が必要）
1. TestFlightタブ → **外部テスト** → グループを作成
2. テスト内容の説明（What to Test）を記入
3. テスターのメールアドレスを追加、またはパブリックリンクを発行
4. 初回は簡易審査（通常24時間以内）が必要。承認後にテスターへ通知が送られる

ユーザーテストの規模が小さいうち（社内・知人中心）は内部テスターの利用を推奨する。

### 7. テスター側の操作

1. テスターはメールまたはパブリックリンクから招待を受け取る
2. [TestFlightアプリ](https://apps.apple.com/app/testflight/id899247664)（App Store）をインストール
3. 招待リンクを開き、TestFlight経由でWillMeterをインストール
4. アプリ内からのフィードバック送信方法は Issue #37（フィードバック収集手段）を参照

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| Archiveメニューがグレーアウトしている | デスティネーションがシミュレータになっていないか確認し、Any iOS Deviceに変更する |
| 署名エラー（Signing certificate等） | Xcode > Settings > Accounts でApple IDが正しくサインインしているか、Teamが選択されているか確認する |
| 「同じビルド番号は使えない」エラー | `CURRENT_PROJECT_VERSION` をインクリメントしてから再Archiveする |
| アップロード後、TestFlightにいつまでも表示されない | App Store Connectの「アクティビティ」タブでビルドの処理状況・エラーメールを確認する |
| 輸出コンプライアンスの警告が出る | 通常のHTTPS通信のみのアプリであれば「標準的な暗号化のみ使用」を選択すれば審査は不要 |

## 今後の検討事項

- ビルド番号の自動採番（CI連携またはfastlaneの`run_number`活用）
- fastlaneによるArchive〜アップロードの自動化（本手順を数回運用し、負担が大きければ導入を検討）
- 上記はP2として別途Issue化を検討する
