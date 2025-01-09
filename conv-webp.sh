#!/bin/bash
show_help() {
  echo "Usage: $0 [-q 80] [-l] SOURCE_PATH DEST_PATH"
  echo ""
  echo "Options:"
  echo "  -q               Quality. E.g. -q 80, -q 50. From 0 to 100, Default is 75."
  echo "  -l --lossless    Use lossless mode."
  echo "  -h, --help       Show this help message and exit."
  echo ""
  echo "Arguments:"
  echo "  SOURCE_PATH   Path to the directory containing files needs to be converted."
  echo "  DEST_PATH     Path to the directory to save the converted files."
}

# 初始化变量
QUALITY=75
LOSSLESS=0

# 解析命令行选项
while getopts ":q:lh-:" opt; do
  case "${opt}" in
  q)
    QUALITY=${OPTARG}
    ;;
  l)
    LOSSLESS=1
    ;;
  h)
    show_help
    exit 0
    ;;
  -)
    case "${OPTARG}" in
    lossless)
      LOSSLESS=1
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
export QUALITY
export LOSSLESS

convert_to_webp() {
  input_file=$1
  # 扩展名
  # file_ext="${input_file##*.}"
  # 计算输出文件的路径
  relative_path="${input_file#"$SOURCE_DIR"/}"
  output_file="$DEST_DIR/${relative_path%.*}.webp"
  # 已存在则跳过
  if [ -f "output_file" ]; then return 0; fi
  # 创建输出文件所在的目录
  output_file_dir=$(dirname "$output_file")
  mkdir -p "$output_file_dir"
  ffmpeg -hide_banner -loglevel warning -i "$input_file" -quality $QUALITY -lossless $LOSSLESS "$output_file"
}

export -f convert_to_webp

# 查找所有文件并处理
find "$SOURCE_DIR" -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" |
  parallel --progress convert_to_webp
