# 0003. UI変更通知をViewModelへ集約する

- 日付: 2026-07-12
- 状態: 採用

## 背景

ウィルパワーの変更通知は `WillPower`、`ObservableWillPower`、`WillPowerViewModel` の3段を経由していた。また、`WillPowerViewModel` は `LocalizationService` protocol を受け取りながら、変更通知を購読するために `SwiftUILocalizationService` へダウンキャストしていた。どちらも現在の実装数とプロダクト規模に対して追跡箇所が多く、ADR 0002 の Simple First 方針に沿った単純化が必要になった。

## 選択肢

1. 現在の通知リレーと protocol を維持する
2. `ObservableWillPower` を `WillPowerViewModel` へ統合し、ローカライズは具体型へ依存する
3. `WillPower` 自体を `ObservableObject` にして SwiftUI に依存させる

## 採用案

選択肢2を採用する。`WillPower` は UI フレームワークから独立したままにし、`WillPowerViewModel` がドメイン変更と言語変更を直接購読する。実装が一つしかなく、ViewModel が変更通知を必要とするローカライズサービスは `SwiftUILocalizationService` を直接受け取る。

## 採用理由

- 値の変更から画面更新までに追う中継クラスを一つ削除できる
- ドメインロジックを SwiftUI から独立してテストできる状態は維持できる
- protocol の能力外にある変更通知をダウンキャストで補う矛盾を解消できる
- 将来別実装が必要になれば、その時点で必要な通知契約を含む抽象を再導入できる

## 欠点・リスク

- ViewModel がドメイン変更の購読を担当する
- ローカライズ実装の差し替えには具体型または新しい抽象の導入が必要になる

## 再評価条件

- SwiftUI 以外の複数UIから同じ監視可能モデルを共有する必要が生じる
- ローカライズサービスに本番用とテスト用など複数実装が必要になる
- ViewModel 間で同じ通知購読コードが重複する

## 影響範囲

- `WillPowerViewModel`
- `WillPowerUseCase`
- `ObservableWillPower` の削除
- `LocalizationService` protocol の削除
- 関連する単体テスト
