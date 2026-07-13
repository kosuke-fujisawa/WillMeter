#!/bin/bash

set -uo pipefail

PLATFORM_NAME="${PLATFORM_NAME:-$(uname -s)}"
if [[ "$PLATFORM_NAME" != "Darwin" ]]; then
    echo "SKIP: macOS専用のTestFlight配布テストです"
    exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_PATH="${SCRIPT_PATH:-$REPO_ROOT/scripts/upload-testflight.sh}"
EXPORT_OPTIONS_PATH="${EXPORT_OPTIONS_PATH:-$REPO_ROOT/Config/TestFlightExportOptions.plist}"
CRASH_TEST_VIEW_PATH="$REPO_ROOT/WillMeter/Presentation/Views/CrashReportTestSection.swift"
failures=0

pass() {
    echo "PASS: $1"
}

fail() {
    echo "FAIL: $1"
    failures=$((failures + 1))
}

assert_contains() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    if [[ "$actual" == *"$expected"* ]]; then
        pass "$description"
    else
        fail "$description"
    fi
}

assert_not_contains() {
    local actual="$1"
    local unexpected="$2"
    local description="$3"

    if [[ "$actual" != *"$unexpected"* ]]; then
        pass "$description"
    else
        fail "$description"
    fi
}

if [[ -f "$SCRIPT_PATH" ]]; then
    pass "TestFlightアップロードスクリプトが存在する"
else
    fail "TestFlightアップロードスクリプトが見つかりません"
fi

if [[ -f "$EXPORT_OPTIONS_PATH" ]]; then
    pass "ExportOptions plistが存在する"
else
    fail "ExportOptions plistが見つかりません"
fi

if [[ -f "$SCRIPT_PATH" && -f "$EXPORT_OPTIONS_PATH" ]]; then
    dry_run_output="$(DEVELOPMENT_TEAM=TESTTEAM bash "$SCRIPT_PATH" --dry-run 2>&1)"
    dry_run_status=$?

    if [[ $dry_run_status -eq 0 ]]; then
        pass "dry-runが成功する"
    else
        fail "dry-runが成功する"
    fi

    assert_contains "$dry_run_output" "archive" "dry-runにarchive処理が含まれる"
    assert_contains "$dry_run_output" "/Volumes/T7\\ Shield/DerivedData" "DerivedDataを外付けドライブへ保存する"
    assert_contains "$dry_run_output" "-exportArchive" "dry-runにApp Store Connectアップロード処理が含まれる"
    assert_contains "$dry_run_output" "-exportPath" "アップロード処理にexportPathが含まれる"
    assert_not_contains "$dry_run_output" "CRASH_REPORT_TESTING" "通常のArchiveにクラッシュ検証機能を含めない"

    crash_test_output="$(DEVELOPMENT_TEAM=TESTTEAM bash "$SCRIPT_PATH" --enable-crash-test --dry-run 2>&1)"
    crash_test_status=$?
    if [[ $crash_test_status -eq 0 ]]; then
        pass "クラッシュ検証ビルドのdry-runが成功する"
    else
        fail "クラッシュ検証ビルドのdry-runが成功する"
    fi
    assert_contains "$crash_test_output" "CRASH_REPORT_TESTING" "クラッシュ検証ビルドだけにコンパイル条件を渡す"

    custom_derived_data_output="$(
        DERIVED_DATA_PATH=/tmp/WillMeterDerivedData \
            DEVELOPMENT_TEAM=TESTTEAM \
            bash "$SCRIPT_PATH" --dry-run 2>&1
    )"
    assert_contains "$custom_derived_data_output" "/tmp/WillMeterDerivedData" "DerivedDataの保存先を環境変数で上書きできる"

    missing_team_output="$(env -u DEVELOPMENT_TEAM bash "$SCRIPT_PATH" 2>&1)"
    missing_team_status=$?
    if [[ $missing_team_status -ne 0 ]]; then
        pass "Developer Team未指定時は失敗する"
    else
        fail "Developer Team未指定時は失敗する"
    fi
    assert_contains "$missing_team_output" "DEVELOPMENT_TEAM" "Developer Team未指定の理由を表示する"

    method="$(/usr/libexec/PlistBuddy -c 'Print :method' "$EXPORT_OPTIONS_PATH")"
    destination="$(/usr/libexec/PlistBuddy -c 'Print :destination' "$EXPORT_OPTIONS_PATH")"
    manages_build_number="$(/usr/libexec/PlistBuddy -c 'Print :manageAppVersionAndBuildNumber' "$EXPORT_OPTIONS_PATH")"
    signing_style="$(/usr/libexec/PlistBuddy -c 'Print :signingStyle' "$EXPORT_OPTIONS_PATH")"
    upload_symbols="$(/usr/libexec/PlistBuddy -c 'Print :uploadSymbols' "$EXPORT_OPTIONS_PATH")"

    [[ "$method" == "app-store-connect" ]] && pass "App Store Connect配布を指定する" || fail "App Store Connect配布を指定する"
    [[ "$destination" == "upload" ]] && pass "exportではなくuploadを指定する" || fail "exportではなくuploadを指定する"
    [[ "$manages_build_number" == "true" ]] && pass "Xcodeのビルド番号自動管理を有効にする" || fail "Xcodeのビルド番号自動管理を有効にする"
    [[ "$signing_style" == "automatic" ]] && pass "自動署名を指定する" || fail "自動署名を指定する"
    [[ "$upload_symbols" == "true" ]] && pass "dSYMシンボルのアップロードを有効にする" || fail "dSYMシンボルのアップロードを有効にする"
fi

if [[ -f "$CRASH_TEST_VIEW_PATH" ]]; then
    pass "クラッシュレポート検証UIが存在する"
    crash_test_view_source="$(<"$CRASH_TEST_VIEW_PATH")"
    assert_contains "$crash_test_view_source" "#if CRASH_REPORT_TESTING" "検証UIをコンパイル条件で隔離する"
    assert_contains "$crash_test_view_source" "confirmationDialog" "意図的クラッシュ前に確認する"
    assert_contains "$crash_test_view_source" "fatalError" "検証用クラッシュを発生できる"
else
    fail "クラッシュレポート検証UIが存在する"
fi

if [[ $failures -gt 0 ]]; then
    echo "$failures test(s) failed"
    exit 1
fi

echo "All TestFlight upload tests passed"
