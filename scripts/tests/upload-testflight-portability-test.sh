#!/bin/bash

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_SCRIPT_PATH="$REPO_ROOT/scripts/tests/upload-testflight-test.sh"
failures=0

pass() {
    echo "PASS: $1"
}

fail() {
    echo "FAIL: $1"
    failures=$((failures + 1))
}

non_macos_output="$(PLATFORM_NAME=Linux bash "$TEST_SCRIPT_PATH" 2>&1)"
non_macos_status=$?

if [[ $non_macos_status -eq 0 && "$non_macos_output" == *"SKIP: macOS専用"* ]]; then
    pass "非macOSではTestFlight固有テストをスキップする"
else
    fail "非macOSではTestFlight固有テストをスキップする"
fi

missing_script_output="$(
    PLATFORM_NAME=Darwin \
        SCRIPT_PATH=/nonexistent/upload-testflight.sh \
        EXPORT_OPTIONS_PATH="$REPO_ROOT/Config/TestFlightExportOptions.plist" \
        bash "$TEST_SCRIPT_PATH" 2>&1
)"
missing_script_status=$?
if [[ $missing_script_status -ne 0 && "$missing_script_output" == *"FAIL: TestFlightアップロードスクリプトが見つかりません"* ]]; then
    pass "アップロードスクリプトがない場合の理由を正しく表示する"
else
    fail "アップロードスクリプトがない場合の理由を正しく表示する"
fi

missing_export_options_output="$(
    PLATFORM_NAME=Darwin \
        SCRIPT_PATH="$REPO_ROOT/scripts/upload-testflight.sh" \
        EXPORT_OPTIONS_PATH=/nonexistent/TestFlightExportOptions.plist \
        bash "$TEST_SCRIPT_PATH" 2>&1
)"
missing_export_options_status=$?
if [[ $missing_export_options_status -ne 0 && "$missing_export_options_output" == *"FAIL: ExportOptions plistが見つかりません"* ]]; then
    pass "ExportOptionsがない場合の理由を正しく表示する"
else
    fail "ExportOptionsがない場合の理由を正しく表示する"
fi

if [[ $failures -gt 0 ]]; then
    echo "$failures test(s) failed"
    exit 1
fi

echo "All TestFlight portability tests passed"
