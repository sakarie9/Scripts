#!/bin/bash

show_help() {
  echo "Usage: $0 [-d] PATH"
  echo ""
  echo "Options:"
  echo "  -d            Delete the original files after conversion."
  echo "  -h, --help    Show this help message and exit."
  echo ""
  echo "Arguments:"
  echo "  PATH          Path to the directory containing .wav files."
  echo "                If PATH is not provided, the current directory is used."
}

# 初始化变量
rm_flag=false

# 解析命令行选项
while getopts "dh-:" opt; do
  case $opt in
  d)
    rm_flag=true
    ;;
  h)
    show_help
    exit 0
    ;;
  -)
    case "${OPTARG}" in
    help)
      show_help
      exit 0
      ;;
    *)
      echo "Invalid option: --${OPTARG}" >&2
      exit 1
      ;;
    esac
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# 移除已处理的选项参数
shift $((OPTIND - 1))

directory="$1"
if [ -n "$directory" ]; then
  cd directory || exit
fi

function wav-flac() {
  find . -iname "*.wav" -type f | parallel -I% --max-args 1 \
    "ffmpeg -i % -c:a flac -y {.}.flac; \
    touch -r % {.}.flac; \
    if [ '$rm_flag' = true ]; then rm -vf %; fi; \
    echo 'Conversion of % completed.'"
}

function wav-opus() {
  find . -iname "*.wav" -type f | parallel -I% --max-args 1 \
    "ffmpeg -i % -c:a libopus -b:a 192K -vbr on -map_metadata 0 -compression_level 10 -y {.}.opus; \
    touch -r % {.}.opus; \
    if [ '$rm_flag' = true ]; then rm -vf %; fi; \
    echo 'Conversion of % completed.'"
}

function flac-opus() {
  find . -iname "*.flac" -type f | parallel -I% --max-args 1 \
    "ffmpeg -hide_banner -loglevel warning -i % -c:a libopus -b:a 192K -vbr on -map_metadata 0 -compression_level 10 -y {.}.opus; \
    touch -r % {.}.opus; \
    if [ '$rm_flag' = true ]; then rm -vf %; fi; \
    echo 'Conversion of % completed.'"
}

if [[ $(basename "$0") == ffmpeg-wav-flac ]]; then
  wav-flac
elif [[ $(basename "$0") == ffmpeg-wav-opus ]]; then
  wav-opus
elif [[ $(basename "$0") == ffmpeg-flac-opus ]]; then
  flac-opus
else
  echo "Unknown function"
  exit 1
fi
