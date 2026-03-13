#!/bin/bash
# scripts/list_md_files.sh

# 尋找所有 .md 與 .mdx 檔案，排除 PROGRESS.md 以及已經是 _zh_TW 的檔案
find . -type f \( -name "*.md" -o -name "*.mdx" \) \
  ! -name "PROGRESS.md" \
  ! -name "*_zh_TW.md" \
  ! -name "*_zh_TW.mdx" \
  ! -path "*/node_modules/*" \
  ! -path "*/.git/*" \
  ! -path "*/dist/*"
