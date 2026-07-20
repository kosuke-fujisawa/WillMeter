# 0007. v2ドメインデータを単一JSONスナップショットへ保存しv1値を線形移行する

- 日付: 2026-07-21
- 状態: 採用

## 背景

WillMeter v2では、現在値だけでなく、好調時の目安、アプリ状態、WillMeterDay、ActivityLog、カテゴリ、サブカテゴリを整合した状態で保存する必要がある。特に、行動記録の確定では現在値・行動記録・所属日を、一日終了では行動記録・日状態・アプリ状態を同時に更新する。

要求仕様はJSONファイルを正本とし、一時ファイルからの置換と1世代バックアップを求めている。一方、当初の参考案どおりに状態・日・行動記録・カテゴリを別ファイルへ分けると、FoundationのファイルAPIだけでは複数ファイルを1つのトランザクションとして置換できない。クラッシュや容量不足がファイル間の更新途中で発生すると、活動中の日と現在値、または行動記録と集計が食い違う可能性がある。

TestFlight版は、UserDefaultsの `willPower.currentValue` と `willPower.maxValue` に0〜最大値のモデルを保存している。v2は「最大ウィルパワー」を廃止し、現在値を−10〜+10の表示基準で扱うため、値をそのまま引き継ぐことはできない。ただし、既存利用者の自己記録を説明なく破棄することも避けたい。

この決定はIssue #73で、後続の初期設定、記録、履歴、保存実装が共有する永続化契約を確定するために行う。

## 選択肢

1. ドメインデータを種類ごとの複数JSONへ保存し、v1データは破棄する
2. ドメインデータを単一JSONスナップショットへ保存し、v1の相対値をv2へ移行する
3. SwiftDataへ保存し、v1の相対値をv2へ移行する

## 採用案

選択肢2を採用する。

### 保存単位

ドメインデータの正本を次の単一スナップショットとする。

```text
Application Support/WillMeter/
├── willmeter-data.json
└── willmeter-data.backup.json
```

書込み中だけ同じディレクトリに `willmeter-data.tmp` を作成する。ViewやViewModelはファイルを直接操作せず、保存境界を担当する型を経由する。実装が1つである間は、形式だけのprotocol階層を追加しない。

UserDefaultsはテーマ、モノクロモード、選択中タブ、`selected_language`、v1移行完了フラグなどの軽量設定に限定する。プレミアム権利はStoreKit 2を正本とし、JSONへ複製しない。オンボーディング完了状態はJSON内のアプリ状態から判断し、既存の `hasCompletedOnboarding` をv2の正本にはしない。

### ルートスキーマ

初期形式の `dataFormatVersion` は1とする。「WillMeter v2」という製品バージョンとは別に、JSON形式だけを独立して採番する。

```json
{
  "dataFormatVersion": 1,
  "state": {},
  "days": [],
  "activityLogs": [],
  "categories": [],
  "subcategories": [],
  "tipStates": [],
  "metadata": {}
}
```

| 要素 | 責務 |
|---|---|
| `state` | `uninitialized` / `activeDay` / `awaitingDayStart`、現在値、好調時の目安、関連する日ID |
| `days` | WillMeterDayの開始・終了値、開始・終了時刻、状態 |
| `activityLogs` | 通常記録、補正、日開始、日終了、v1移行記録と、記録時点のスナップショット |
| `categories` | カテゴリの名称、表示順、論理削除状態 |
| `subcategories` | 所属カテゴリ、名称、変化量、システム種別、表示順、論理削除状態 |
| `tipStates` | Tipsの閲覧状態。コンテンツ本体はアプリ同梱リソースを正本とする |
| `metadata` | 作成・更新日時、移行元、保存形式に関するメタデータ |

IDはUUID文字列、日時は小数秒とタイムゾーンを含むISO 8601文字列で保存する。配列順を意味の正本にせず、記録は `recordedAt` と `sequenceNumber`、カテゴリ類は `sortOrder` で並べる。

初期形式で各要素が持つ最小フィールドを次のとおり固定する。実装上のSwift型やファイル分割を固定するものではないが、保存名と意味を変える場合は `dataFormatVersion` の移行が必要になる。

| 要素 | 最小フィールド |
|---|---|
| `state` | `status`, `currentValue`, `personalBaseline`, `activeDayID`, `lastCompletedDayID` |
| `WillMeterDay` | `id`, `startedAt`, `endedAt`, `startValue`, `endValue`, `status`, `createdAt`, `updatedAt` |
| `ActivityLog` | `id`, `dayID`, `recordType`, `direction`, `delta`, `beforeValue`, `afterValue`, `categoryID`, `subcategoryID`, `categoryNameSnapshot`, `subcategoryNameSnapshot`, `systemTypeSnapshot`, `recordedAt`, `createdAt`, `updatedAt`, `sequenceNumber`, `isCancelled` |
| `Category` | `id`, `name`, `sortOrder`, `isActive`, `createdAt`, `updatedAt` |
| `SubCategory` | `id`, `categoryID`, `name`, `delta`, `systemType`, `sortOrder`, `isActive`, `createdAt`, `updatedAt` |
| `TipState` | `tipID`, `hasBeenViewed`, `viewedAt` |
| `metadata` | `createdAt`, `updatedAt`, `migratedFrom`, `migratedAt` |

`state.status` ごとの必須組合せは次のとおりとする。

- `uninitialized`: 現在値、好調時の目安、関連日IDを持たない
- `activeDay`: 現在値、好調時の目安、存在する `activeDayID` を持つ
- `awaitingDayStart`: 前日終了時点の現在値、好調時の目安、存在する `lastCompletedDayID` を持ち、`activeDayID` は持たない

ActivityLogの `recordType` は初期形式では `normal` / `adjustment` / `dayStart` / `dayEndingSleep` / `migration` とする。カテゴリやサブカテゴリを参照しないシステム記録では、関連IDと名称スナップショットをnullにできる。`nap` は日を終了しない回復の通常記録とし、`systemTypeSnapshot == nap` で識別する。

`direction` は通常記録では必須とし、補正では `delta` の符号と一致させる。`delta == 0` の補正、日開始、日終了、移行記録ではnullにできる。すべての記録で `beforeValue + delta == afterValue` を満たし、日開始・日終了・移行記録は `delta == 0` とする。

### 最小データ契約

- 現在値はIntとし、通常の操作では上限・下限へクランプしない。永続化境界では、state、WillMeterDay、ActivityLogに保存するウィルパワー値を破損防御として−999〜999だけ受け付け、範囲外を黙って丸めず保存エラーとして扱う。
- 好調時の目安は1〜10とする。現在値の上限には使用しない。
- 通常のActivityLogは、ID、所属日ID、記録種別、方向、変化量、記録前後値、カテゴリ/サブカテゴリIDと名称スナップショット、記録日時、作成/更新日時、sequenceNumber、取消状態を持つ。
- 通常記録の変化量は−10〜−1または1〜10とする。補正・日開始・日終了・移行記録は通常記録と区別し、カテゴリ分析対象外とする。
- CategoryとSubCategoryは物理削除せず `isActive` で論理削除する。過去表示はActivityLogのスナップショットを使う。
- デコード後かつドメインへ渡す前に、下表の不変条件をスナップショット全体で検証する。

### 不変条件と保存データの対応

| # | 不変条件 | 検証方法 |
|---|---|---|
| 1 | 活動中のWillMeterDayは最大1件 | `days.status == active` の件数と `state.activeDayID` の一致を検証 |
| 2 | 行動記録は必ず1つの日に所属 | 全 `activityLogs.dayID` の参照先が存在することを検証 |
| 3 | 通常記録の変化量は0ではない | 通常記録だけ符号付き範囲を検証 |
| 4 | 消費は負 | `direction == consume` と負値の組合せを検証 |
| 5 | 回復は正 | `direction == restore` と正値の組合せを検証 |
| 6 | 記録後値を前値と変化量から算出できる | `beforeValue + delta == afterValue` をオーバーフローなしで検証 |
| 7 | カテゴリ削除後も履歴表示可能 | 通常記録の名称・値スナップショットを必須化 |
| 8 | 設定値変更は過去記録へ遡及しない | 集計・表示は記録側スナップショットを使用 |
| 9 | 再設定は過去履歴を変更しない | 再設定時に既存ログを書換えない契約とする |
| 10 | 午前0時だけでは日を終了しない | カレンダー日付を状態遷移条件に含めない |
| 11 | 仮眠は日を終了しない | `nap` は通常回復記録として扱う |
| 12 | 一日を終える睡眠が次の日の開始契機 | 日終了記録後の状態を `awaitingDayStart` に限定 |
| 13 | 翌日開始値は前日終了値と独立 | 各WillMeterDayが `startValue` / `endValue` を個別保持 |
| 14 | プレミアム権利は記録データを変えない | 権利をJSONスナップショット外のStoreKit 2で管理 |

### 保存・復旧手順

保存は次の順序で行う。

1. メモリ上のスナップショット全体を検証する
2. `willmeter-data.tmp` へエンコードして書込みを同期する
3. 一時ファイルを再読込みし、デコードと不変条件検証を行う
4. 現在の正本が正常なら、正本からバックアップを1世代更新する
5. 一時ファイルで正本を原子的に置換する
6. 保存失敗時はメモリ上の新しい状態を維持し、未保存状態として上位へ通知する

起動時は正本を先に読み、デコードまたは不変条件検証に失敗した場合だけバックアップを読む。バックアップから復旧した事実は上位へ通知する。両方が失敗した場合はファイルを自動上書きせず、回復不能な読込みエラーとして利用者へ明示する。

### v1からの移行

v2正本もバックアップも存在せず、v1移行完了フラグも立っていない初回起動だけ、次のUserDefaultsキーを読む。

- `willPower.currentValue`
- `willPower.maxValue`

両方がIntで `maxValue > 0` の場合、v1の最大値に対する相対位置をv2の標準表示範囲へ線形変換する。

```text
boundedCurrent = min(max(currentValue, 0), maxValue)
migratedValue = round((Double(boundedCurrent) / Double(maxValue)) * 20 - 10)
```

例: 0/100 → −10、50/100 → 0、70/100 → 4、100/100 → 10。

移行時は次を1つのスナップショットとして保存する。

- 現在値: `migratedValue`
- 好調時の目安: 10
- アプリ状態: `activeDay`
- WillMeterDay: 移行時刻開始、`startValue == migratedValue`
- ActivityLog: 変化量0の `migration` 記録を1件。通常記録と区別し、分析から除外する
- metadata: v1 UserDefaultsから移行した事実と移行日時

v1キーが欠損、型不一致、または `maxValue <= 0` の場合は推測で補完せず、v2を `uninitialized` として初期設定を求める。

移行完了フラグはv2正本の保存と再読込み検証に成功した後だけUserDefaultsへ記録する。v1キーは移行直後には削除せず、旧TestFlight版へ戻した場合の手掛かりとして当面読取り専用で残す。ただしv2の全データ削除では、正本・バックアップ・一時ファイル・v1キーを削除し、移行完了フラグを維持して古い値の再取込みを防ぐ。

移行完了後に正本とバックアップの両方が破損しても、更新されていないv1値へ自動で戻してはならない。破損を明示し、利用者の確認なしに新規状態で上書きしない。

### 保存形式の更新

読込み時は `dataFormatVersion` を最初に確認する。古い形式は明示的な段階移行関数を通し、現在形式へ変換後に全不変条件を検証する。アプリが理解できない新しい形式は上書きせず、非対応バージョンエラーとする。

### 設計検証ケース

後続実装では少なくとも次を自動テストし、このADRの契約を満たすことを確認する。

| 状態 | 期待結果 |
|---|---|
| v2ファイルなし、v1キーなし | `uninitialized` として初期設定を表示する |
| v2ファイルなし、有効なv1キー70/100 | 現在値4、好調時の目安10の活動中の日へ一度だけ移行する |
| v1キーが片方だけ、型不一致、またはmaxValueが0以下 | 推測で移行せず `uninitialized` とする |
| 正本が有効 | バックアップを読まず正本を返す |
| 正本が破損、バックアップが有効 | バックアップを返し、復旧した事実を上位へ通知する |
| 正本とバックアップがともに破損 | 初期値で上書きせず読込みエラーを返す |
| `dataFormatVersion` が対応する旧版 | 段階移行後に全不変条件を検証して返す |
| `dataFormatVersion` がアプリより新しい | ファイルを変更せず非対応バージョンエラーを返す |
| 移行完了後にv2ファイルが消失し、v1キーだけ残る | 古いv1値を再移行せず、回復または初期設定を求める |
| 全データ削除 | v2ファイル、バックアップ、一時ファイル、v1キーを削除し、再移行を防止する |

## 採用理由

- 1回の利用操作で変わる全データを1回の原子的置換にまとめられる
- 複数ファイル間トランザクションや先行抽象化が不要で、ADR 0002のSimple Firstに合う
- データ量が小さい初期リリースでは、全体エンコードのコストより整合性と理解しやすさの利点が大きい
- JSONは内容と形式versionを人間が確認でき、CSVエクスポートや将来移行の入力にも使いやすい
- v1の相対位置を移すことで、概念が異なる値をそのまま流用せず、既存利用者の状態も説明可能な形で残せる
- 移行記録とmetadataに由来を残すため、通常行動の分析を汚さない

## 欠点・リスク

- 記録件数が増えると、1件の変更でもスナップショット全体のエンコードと置換が必要になる
- v1からの線形変換は主観値を完全には再現できず、70/100をv2の4とみなすことに違和感が出る可能性がある
- 1世代バックアップのため、2回連続で破損状態を正常と誤判定すると回復できない
- v1キーを残す期間は、UserDefaultsとJSONに異なる世代の値が併存する。ただしv2はJSONだけを正本とし、二重書込みは行わない
- −999〜999の保存防御範囲へ実利用値が到達した場合、未保存エラーとして利用者対応が必要になる

## 再評価条件

次のいずれかが生じた場合、この決定を見直す。

- 実測でファイルサイズまたは保存時間が通常操作に無視できない遅延を生む
- 記録件数の増加により、全体読込みが起動2秒以内の目標を継続的に満たせない
- iCloud同期や複数端末マージを導入し、レコード単位の競合解決が必要になる
- 1世代バックアップでは回復できない破損が実際に発生する
- v1移行のユーザーテストで線形変換より初期設定のやり直しが明確に支持される

再評価時も、利用箇所のない汎用Repository階層は先行導入せず、計測結果と具体的な同期要件に合わせてSQLite、SwiftData、または分割JSONを比較する。

## 影響範囲

- Issue #74以降で実装するv2ドメイン型と保存境界
- `UserDefaultsWillPowerRepository`からv2保存への移行処理
- 全データ削除、保存失敗表示、バックアップ復旧
- 日次履歴、分析、CSVエクスポートが読むデータ契約
- `docs/requirements/willmeter-v2-requirements.md` の保存方式、ギャップ分析、未確定事項
- ADR 0001の日境界方針、ADR 0002のSimple First方針（いずれも維持）
