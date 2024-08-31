#!/bin/bash

show_help() {
  echo "Usage: $0 [-b 96] [-c] SOURCE_PATH DEST_PATH"
  echo ""
  echo "Options:"
  echo "  -b               Opus Bitrate. E.g. -b 96, -b 128. Default is 96."
  echo "  -c --audio-only  If copy other files in the source directory."
  echo "  -h, --help       Show this help message and exit."
  echo ""
  echo "Arguments:"
  echo "  SOURCE_PATH   Path to the directory containing files needs to be converted."
  echo "  DEST_PATH     Path to the directory to save the converted files."
}

# 初始化变量
BITRATE=96
CACHE_DIR="/tmp/opus-convert"
AUDIO_ONLY=false

# 解析命令行选项
while getopts ":b:ch-:" opt; do
  case "${opt}" in
  b)
    BITRATE=${OPTARG}
    ;;
  c)
    AUDIO_ONLY=true
    ;;
  h)
    show_help
    exit 0
    ;;
  -)
    case "${OPTARG}" in
    audio-only)
      AUDIO_ONLY=true
      ;;
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
  :)
    echo "Option -${OPTARG} requires an argument." >&2
    exit 1
    ;;
  esac
done
# 移除已处理的选项参数
shift $((OPTIND - 1))

# 检查参数是否足够
if [ $# -ne 2 ]; then
  echo "Error: SOURCE_PATH and DEST_PATH are required."
  show_help
  exit 1
fi

# 获取参数
SOURCE_DIR="${1%/}"
DEST_DIR="${2%/}"

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

# 创建目标目录（如果不存在）
mkdir -p "$DEST_DIR"

# 导出环境变量
export SOURCE_DIR
export DEST_DIR
export BITRATE
export CACHE_DIR

# 查找源目录中的所有MP3文件并使用parallel进行多线程转换
# find "$SOURCE_DIR" -type f -name "*.mp3" -o -name "*.wav" -o -name "*.flac" | parallel --progress -j "$(nproc)" ffmpeg -n -hide_banner -loglevel warning -i {} -c:a libopus -b:a 96K "$DEST_DIR/{/.}.opus"

convert_to_opus() {
  input_file=$1
  # 扩展名
  # file_ext="${input_file##*.}"
  # 计算输出文件的路径
  relative_path="${input_file#"$SOURCE_DIR"/}"
  output_file="$DEST_DIR/${relative_path%.*}.opus"
  # 已存在则跳过
  if [ -f "output_file" ]; then return 0; fi
  # 创建输出文件所在的目录
  output_file_dir=$(dirname "$output_file")
  mkdir -p "$output_file_dir"
  # -c:v copy is REQUIRED as FFmpeg will convert the album cover, cause extremely large files
  ffmpeg -hide_banner -loglevel warning -i "$input_file" -c:v copy -f flac - | opusenc --quiet --bitrate "$BITRATE" - "$output_file"
}

convert_to_opus_compress_cover() {
  input_file=$1
  # 计算输出文件的路径
  relative_path="${input_file#"$SOURCE_DIR"/}"
  output_file="$DEST_DIR/${relative_path%.*}.opus"
  # 缓存
  cover_convert_file="$CACHE_DIR/${relative_path%.*}.jpg"
  mkdir -p "$(dirname "$cover_convert_file")"
  # 已存在则跳过
  if [ -f "output_file" ]; then return 0; fi
  # 创建输出文件所在的目录
  output_file_dir=$(dirname "$output_file")
  mkdir -p "$output_file_dir"
  # 提取并压缩封面
  ffmpeg -hide_banner -loglevel warning -i "$input_file" -an -vcodec copy -f image2pipe - |
    ffmpeg -hide_banner -loglevel warning -i - -vf "scale='if(gt(iw,1000),1000,iw)':-1" "$cover_convert_file"
  # 转换并嵌入封面
  ffmpeg -hide_banner -loglevel warning \
    -i "$input_file" -i "$cover_convert_file" -map 0:a -map 1:v -c:v copy -disposition:v attached_pic -metadata:s:v comment="Cover (front)" -f flac - |
    opusenc --quiet --bitrate "$BITRATE" - "$output_file"
  # 清理缓存
  rm "$cover_convert_file"
}

export -f convert_to_opus
export -f convert_to_opus_compress_cover

# 查找所有 flac 文件并处理
#find "$SOURCE_DIR" -type f -name "*.flac" -o -name "*.mp3" -o -name "*.wav" |
#  parallel --progress convert_to_opus
find "$SOURCE_DIR" -type f -name "*.flac" -o -name "*.mp3" -o -name "*.wav" |
  parallel --progress convert_to_opus_compress_cover
# 复制其他文件到目标目录
if [ $AUDIO_ONLY = false ]; then
  # rsync -a --exclude='Scans/' --include='*/' --include='*.lrc' --include='*.jpg' --include='*.png' --include='*.webp' --exclude='*' "$SOURCE_DIR/" "$DEST_DIR/"
  rsync -a --include='*/' --include='*.lrc' --include='*.jpg' --include='*.png' --include='*.webp' --exclude='*' "$SOURCE_DIR/" "$DEST_DIR/"
fi
