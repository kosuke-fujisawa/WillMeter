#!/bin/bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$REPO_ROOT/WillMeter.xcodeproj"
EXPORT_OPTIONS_PATH="$REPO_ROOT/Config/TestFlightExportOptions.plist"
DERIVED_DATA_PATH="/Volumes/T7 Shield/DerivedData"
RUN_ID="$(date '+%Y%m%d-%H%M%S')"
TEMP_ROOT="${TMPDIR:-/tmp}"
TEMP_ROOT="${TEMP_ROOT%/}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$TEMP_ROOT/WillMeter-$RUN_ID.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$TEMP_ROOT/WillMeter-export-$RUN_ID}"
DRY_RUN=false

usage() {
    cat <<'EOF'
Usage: DEVELOPMENT_TEAM=<Team ID> scripts/upload-testflight.sh [options]

Options:
  --archive-path <path>  Archiveの保存先を指定する
  --dry-run              実行するxcodebuildコマンドだけを表示する
  --help                 このヘルプを表示する

Prerequisites:
  - XcodeのAccountsにApp Store Connectへ接続できるApple Accountが登録済み
  - mhlyc.WillMeterを配布できるDeveloper Team IDをDEVELOPMENT_TEAMに指定
EOF
}

print_command() {
    printf '  '
    printf '%q ' "$@"
    printf '\n'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --archive-path)
            [[ $# -ge 2 ]] || { echo "Error: --archive-pathには値が必要です" >&2; exit 2; }
            ARCHIVE_PATH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Error: 不明なオプションです: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "${DEVELOPMENT_TEAM:-}" ]]; then
    echo "Error: DEVELOPMENT_TEAMにApple Developer Team IDを指定してください" >&2
    exit 2
fi

if [[ ! -f "$EXPORT_OPTIONS_PATH" ]]; then
    echo "Error: ExportOptionsが見つかりません: $EXPORT_OPTIONS_PATH" >&2
    exit 2
fi

archive_command=(
    xcodebuild
    -project "$PROJECT_PATH"
    -scheme WillMeter
    -configuration Release
    -destination generic/platform=iOS
    -derivedDataPath "$DERIVED_DATA_PATH"
    -archivePath "$ARCHIVE_PATH"
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
    -allowProvisioningUpdates
    archive
)

upload_command=(
    xcodebuild
    -exportArchive
    -archivePath "$ARCHIVE_PATH"
    -exportPath "$EXPORT_PATH"
    -exportOptionsPlist "$EXPORT_OPTIONS_PATH"
    -allowProvisioningUpdates
)

echo "Archive: $ARCHIVE_PATH"
echo "Export logs: $EXPORT_PATH"
echo "XcodeがApp Store Connectへのアップロード時にビルド番号を自動管理します。"

if [[ "$DRY_RUN" == true ]]; then
    echo "Archive command:"
    print_command "${archive_command[@]}"
    echo "Upload command:"
    print_command "${upload_command[@]}"
    exit 0
fi

command -v xcodebuild >/dev/null 2>&1 || {
    echo "Error: xcodebuildが見つかりません" >&2
    exit 2
}

"${archive_command[@]}"
"${upload_command[@]}"

echo "TestFlightへのアップロードを開始しました。App Store Connectで処理結果を確認してください。"
