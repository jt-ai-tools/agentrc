#!/bin/bash
# scripts/check_translations.sh

echo "正在檢查翻譯完整性..."
missing=0
total=0

for file in $(bash scripts/list_md_files.sh); do
    total=$((total + 1))
    zh_file="${file%.*~}_zh_TW.${file##*.}"
    # 修正檔名處理 (處理 .md 與 .mdx)
    base="${file%.*}"
    ext="${file##*.}"
    zh_file="${base}_zh_TW.${ext}"

    if [ ! -f "$zh_file" ]; then
        echo "❌ 缺少翻譯: $file -> $zh_file"
        missing=$((missing + 1))
    fi
done

echo "-----------------------------------"
echo "總計文件: $total"
echo "缺失翻譯: $missing"

if [ $missing -eq 0 ]; then
    echo "✅ 所有文件皆已完成翻譯！"
    exit 0
else
    exit 1
fi
