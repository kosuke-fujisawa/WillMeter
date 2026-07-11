#!/usr/bin/env bash
set -u

mkdir -p .review

report_file=".review/lightweight-review.md"
log_dir=".review/logs"
mkdir -p "$log_dir"

checks=(
  "SwiftLint|swiftlint lint --reporter github-actions-logging"
)

failures=0
summary_rows=()

run_check() {
  local name="$1"
  local command="$2"
  local log_file="$3"

  set +e
  (
    echo "\$ $command"
    echo
    bash -lc "$command"
  ) 2>&1 | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e

  if [ "$status" -eq 0 ]; then
    summary_rows+=("| ${name} | PASS | |")
  else
    failures=$((failures + 1))
    summary_rows+=("| ${name} | FAIL | Actions log |")
  fi
}

for check in "${checks[@]}"; do
  name="${check%%|*}"
  command="${check#*|}"
  safe_name="$(echo "$name" | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-')"
  run_check "$name" "$command" "$log_dir/${safe_name}.log"
done

{
  echo "## Lightweight Review"
  echo
  echo "CodeRabbitのようなAIレビューではなく、毎回必ず回る軽量な自動レビューです。"
  echo
  echo "| Check | Result | Log |"
  echo "| --- | --- | --- |"
  printf '%s\n' "${summary_rows[@]}"
  echo

  if [ "$failures" -eq 0 ]; then
    echo "Result: PASS"
    echo
    echo "SwiftLintが通りました。Unit testsはBuild & Unit Testワークフローで実行されます。"
  else
    echo "Result: FAIL"
    echo
    echo "${failures}件のチェックが失敗しました。Actionsの該当ログを確認してください。"
  fi
} >"$report_file"

if [ "$failures" -eq 0 ]; then
  exit 0
fi

exit 1
