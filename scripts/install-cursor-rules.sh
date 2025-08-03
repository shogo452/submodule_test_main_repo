#!/bin/bash
# プロジェクト用の軽量インストーラー

set -e

CURSOR_RULES_REPO="https://github.com/shogo452/cursor-rules-common.git"

echo "📋 プロジェクト用 Cursor Rules セットアップ"

# submoduleが既に存在するかチェック
if [ -d "cursor-rules-common" ]; then
    echo "📦 既存のsubmoduleを更新中..."
    git submodule update --remote cursor-rules-common
else
    echo "📦 cursor-rules-commonをsubmoduleとして追加中..."
    git submodule add "$CURSOR_RULES_REPO"
fi

# 共通スクリプトを実行
if [ -f "cursor-rules-common/scripts/setup-cursor-rules.sh" ]; then
    echo "🔧 共通セットアップスクリプトを実行中..."
    ./cursor-rules-common/scripts/setup-cursor-rules.sh
else
    echo "❌ セットアップスクリプトが見つかりません"
    exit 1
fi
