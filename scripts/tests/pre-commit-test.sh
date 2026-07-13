#!/bin/bash

set -euo pipefail

REPOSITORY_ROOT=$(cd "$(dirname "$0")/../.." && pwd)

fail() {
    echo "❌ $1"
    exit 1
}

test_partial_staging_is_preserved() {
    local test_repository
    test_repository=$(mktemp -d)
    trap 'rm -rf "$test_repository"' RETURN

    git -C "$test_repository" init --quiet
    git -C "$test_repository" config user.email "test@example.com"
    git -C "$test_repository" config user.name "Test User"
    printf 'let value = 1\n' > "$test_repository/Sample.swift"
    git -C "$test_repository" add Sample.swift
    git -C "$test_repository" commit --quiet -m initial

    printf 'let value = 2   \n' > "$test_repository/Sample.swift"
    git -C "$test_repository" add Sample.swift
    printf 'let value = 2   \nlet unstaged = true\n' > "$test_repository/Sample.swift"

    (
        cd "$test_repository"
        PATH="/usr/bin:/bin" bash "$REPOSITORY_ROOT/scripts/pre-commit"
    )

    local staged_content
    staged_content=$(git -C "$test_repository" show :Sample.swift)
    [[ "$staged_content" == 'let value = 2' ]] || fail "ステージ済み内容だけが整形されていません"

    local working_content
    working_content=$(cat "$test_repository/Sample.swift")
    [[ "$working_content" == $'let value = 2   \nlet unstaged = true' ]] || fail "未ステージの作業ツリーが変更されました"
}

test_all_tracked_files_are_cleaned_and_deleted_file_is_ignored() {
    local test_repository
    test_repository=$(mktemp -d)
    trap 'rm -rf "$test_repository"' RETURN

    git -C "$test_repository" init --quiet
    git -C "$test_repository" config user.email "test@example.com"
    git -C "$test_repository" config user.name "Test User"
    printf 'let deleted = true\n' > "$test_repository/Deleted.swift"
    printf 'let existing = true   \n' > "$test_repository/Existing.swift"
    git -C "$test_repository" add Deleted.swift Existing.swift
    git -C "$test_repository" commit --quiet -m initial
    rm "$test_repository/Deleted.swift"
    printf 'let unstaged = true   \n' > "$test_repository/Existing.swift"

    (
        cd "$test_repository"
        bash "$REPOSITORY_ROOT/scripts/clean-trailing-whitespace.sh" swift
    )

    [[ $(cat "$test_repository/Existing.swift") == 'let unstaged = true' ]] || fail "未ステージ変更のある追跡Swiftファイルが整形されていません"
}

test_partial_staging_is_preserved
test_all_tracked_files_are_cleaned_and_deleted_file_is_ignored

echo "✅ pre-commitスクリプトテスト成功"
