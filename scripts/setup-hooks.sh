#!/bin/bash
#
# WillMeter Git Hooks セットアップスクリプト
# pre-commit hookを自動的にインストール
#

echo "🔧 WillMeter Git Hooks セットアップ開始..."

# scripts ディレクトリの存在確認
if [ ! -d "scripts" ]; then
    echo "❌ scriptsディレクトリが見つかりません"
    exit 1
fi

# pre-commit hookテンプレートの存在確認
if [ ! -f "scripts/pre-commit" ]; then
    echo "❌ scripts/pre-commit テンプレートが見つかりません"
    exit 1
fi

# .git/hooks ディレクトリの存在確認
if [ ! -d ".git/hooks" ]; then
    echo "❌ .git/hooksディレクトリが見つかりません（Gitリポジトリではない可能性があります）"
    exit 1
fi

# pre-commit hookのコピーとアクティベート
echo "   📋 pre-commit hookをコピー中..."
cp scripts/pre-commit .git/hooks/pre-commit

echo "   🔓 pre-commit hookに実行権限を付与中..."
chmod +x .git/hooks/pre-commit

# インストール確認
if [ -x ".git/hooks/pre-commit" ]; then
    echo "✅ Git pre-commit hook インストール完了"
    echo ""
    echo "📝 使用方法:"
    echo "   - コミット時に自動的に末尾空白除去+SwiftLint実行"
    echo "   - 手動実行: .git/hooks/pre-commit"
    echo "   - 無効化: rm .git/hooks/pre-commit"
    echo ""
    echo "🎯 効果:"
    echo "   - trailing whitespace問題の完全防止"
    echo "   - SwiftLint品質チェック自動化"
    echo "   - コード品質の継続的保証"
else
    echo "❌ pre-commit hookのインストールに失敗しました"
    exit 1
fi

echo "🎉 WillMeter Git Hooks セットアップ完了"