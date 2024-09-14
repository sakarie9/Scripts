#!/bin/bash

# 获取传入的文件/目录列表
paths=("$@")

# 获取第一个选中的项目
first_item="${paths[0]}"

# 如果是单个文件
if [ ${#paths[@]} -eq 1 ] && [ -f "$first_item" ]; then
  # 获取文件名和扩展名
  filename=$(basename "$first_item")
  base="${filename%.*}"
  dir=$(dirname "$first_item")
  output="$dir/$base.7z"

# 如果是多个文件
elif [ ${#paths[@]} -gt 1 ]; then
  # 使用当前目录名作为文件名
  dir=$(dirname "$first_item")
  current_dir=$(basename "$dir")
  output="$dir/$current_dir.7z"

# 如果是目录
elif [ -d "$first_item" ]; then
  dir=$(dirname "$first_item")
  dirname=$(basename "$first_item")
  output="$dir/$dirname.7z"
fi

# 压缩到 .7z 格式
7z -m0=flzma2 a "$output" "${paths[@]}"

read -p "压缩完成，按回车键继续..."
