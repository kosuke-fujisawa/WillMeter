# 0006. 最小対応iOSバージョンを17.0へ引き下げる

- 日付: 2026-07-18
- 状態: 採用

## 背景

最小対応OSがiOS 18.5というポイントリリース指定になっており、iOS 18.0〜18.4のままの端末でもTestFlightビルドをインストールできない。ユーザーテストのテスター募集で対応端末が障壁になりうる（Issue #42）。

公開されている普及状況（2026年6月時点）では、iOS 26が約79%、iOS 18が約10〜14%、iOS 17以下が残り約7〜10%を占める。ハードウェア面ではiOS 17とiOS 18の対応機種は同一（iPhone XS以降）で、iOS 16まで下げた場合のみiPhone 8/X（2017年機種）が加わる。

## 選択肢

1. iOS 18.5のまま維持する
2. iOS 17.0へ引き下げる
3. iOS 16.0へ引き下げる

## 採用案

iOS 17.0へ引き下げる。

## 採用理由

- コードベースにiOS 18固有のAPIは存在せず、`swiftc -target arm64-apple-ios17.0-simulator`での型チェック（availability検査）が通常ビルド・`CRASH_REPORT_TESTING`有効ビルドともコード変更なしで成功する
- ポイントリリース指定（18.5）が課すOS更新の手間をなくし、OSを更新していないiOS 17/18ユーザーもテスターにできる
- iOS 16.0まで下げる場合は`LanguageSettingsView`の`fill().stroke()`チェーン（iOS 17 API）の書き換えが必要になるが、追加で得られるのは2017年機種のみで、2026年時点のシェアに対して修正・検証コストが見合わない

## 欠点・リスク

- iOS 17実機・シミュレーターでの動作確認が検証対象に加わる
- 今後iOS 18以降のAPIを使う場合は`#available`分岐か、このADRの再評価が必要になる

## 再評価条件

- iOS 18以降のAPIを`#available`分岐なしで使いたい機能要求が出たとき
- iOS 17以下の利用シェアが無視できる水準まで低下したとき
- App StoreまたはXcodeの要件により最小バージョンの引き上げが必要になったとき

## 影響範囲

- `WillMeter.xcodeproj`の`IPHONEOS_DEPLOYMENT_TARGET`（全ビルド構成: 18.5 → 17.0）
- CLAUDE.md / README.mdの技術要件記載

## 参考資料

- [Issue #42](https://github.com/kosuke-fujisawa/WillMeter/issues/42)
- [Apple Developer: App Store でのiOSバージョン利用状況](https://developer.apple.com/support/app-store/)
