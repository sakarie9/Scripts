#!/bin/bash

# 检查是否给定了目录参数
if [ $# -eq 0 ]; then
  # 如果没有给定目录参数，则在当前目录下执行转换
  directory="."
else
  # 如果给定了目录参数，则进入指定目录后执行转换
  directory="$1"
  cd "$directory" || exit
fi

# 转换所有目录下的 .mp3 文件为 .opus
find . -iname "*.mp3" -type f | parallel -I% --max-args 1 \
  "ffmpeg -i % -c:a libopus -b:a 128K -vbr on -map_metadata 0 -compression_level 10 -y {.}.opus; touch -r % {.}.opus; rm -vf %"
