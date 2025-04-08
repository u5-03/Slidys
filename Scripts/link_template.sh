#!/bin/bash

# Xcodeのカスタムテンプレートフォルダ
TEMPLATE_DIR=~/Library/Developer/Xcode/Templates/MySlideTemplates

# プロジェクトディレクトリ（スクリプトがあるディレクトリを基準にする）
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd)/..
# 必要なディレクトリを作成
mkdir -p "$TEMPLATE_DIR"
# 既存のシンボリックリンクを削除（リンクのみ削除し、実体がある場合は残す）
find "$TEMPLATE_DIR" -type l -delete

# Templatesフォルダ内のすべての.xctemplateをシンボリックリンクとして登録
for template in "$PROJECT_DIR/Templates"/*.xctemplate; do
    if [ -d "$template" ]; then
        ln -snf "$template" "$TEMPLATE_DIR/$(basename "$template")"
        echo "Done: $(basename "$template")"
    fi
done

echo "Linked template files!"
