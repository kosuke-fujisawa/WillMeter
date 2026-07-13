#!/bin/bash

set -euo pipefail

scope=${1:-all}

case "$scope" in
    swift)
        patterns=('*.swift')
        ;;
    all)
        patterns=('*.swift' '*.yml' '*.yaml' '*.md')
        ;;
    *)
        echo "Usage: $0 [swift|all]" >&2
        exit 1
        ;;
esac

git ls-files -z -- "${patterns[@]}" |
while IFS= read -r -d '' file; do
    # git ls-filesは未ステージで削除されたパスも返すため、実在する通常ファイルだけを整形する。
    if [[ -f "$file" ]]; then
        sed -i '' 's/[[:space:]]*$//' "$file"
    fi
done
