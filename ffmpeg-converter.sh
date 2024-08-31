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
RM_FLAG=false
OPUS_BITRATE=160

# 解析命令行选项
while getopts "dh-:" opt; do
  case "${opt}" in
  d)
    RM_FLAG=true
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

export RM_FLAG
export OPUS_BITRATE

convert_to_opus() {
  input_file=$1
  output_file="${input_file%.*}.opus"
  # -c:v copy is REQUIRED as FFmpeg will convert the album cover, cause extremely large files
  ffmpeg -hide_banner -loglevel warning -i "$input_file" -c:v copy -f flac - |
    opusenc --quiet --bitrate "$OPUS_BITRATE" - "$output_file"
  if [ $RM_FLAG = true ]; then rm -vf "$input_file"; fi
  echo --- Conversion of "$input_file" completed ---
}

convert_to_flac() {
  input_file=$1
  output_file="${input_file%.*}.flac"
  ffmpeg -hide_banner -loglevel warning -i "$input_file" -c:a flac -y "$output_file"
  if [ $RM_FLAG = true ]; then rm -vf "$input_file"; fi
  echo --- Conversion of "$input_file" completed ---
}

export -f convert_to_opus
export -f convert_to_flac

function wav-flac() {
  find . -iname "*.wav" -type f | parallel --progress convert_to_flac
}

function wav-opus() {
  find . -iname "*.wav" -type f | parallel --progress convert_to_opus
}

function flac-opus() {
  find . -iname "*.flac" -type f | parallel --progress convert_to_opus
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
