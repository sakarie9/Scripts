#!/bin/bash

# Define monitors
monitors=(HDMI-A-3 DVI-D-2)
# Wallpaper directory
wallpaper_dir="${HOME}/Pictures/wallpapers/2024"
#wallpaper_dir=${HOME}/Pictures/wallpapers/sfw

weight_path="$wallpaper_dir/.weight"

get_weight() {
  if [ -f "$weight_path" ]; then
    # 读取 wall.txt 文件的内容
    while read line; do
      # 以逗号为分隔符将每一行拆分成数组
      IFS=, read -r weight_path count <<<"$line"
      # 重复输出文件路径 count 次
      for i in $(seq 1 $count); do
        echo "$weight_path"
      done
    done <$weight_path
  fi
}

# https://github.com/sayanta01/dotfiles/raw/48bf0f345f5a37a22dbae17b1e20564d541fbfee/.local/bin/wallch
apply_wallpaper() {
  set_wallpaper_hyprland_multimonitor() {
    monitor=$1
    BG="$( (
      find "$wallpaper_dir" -name '*.jpg' -o -name '*.png' -o -name '*.webp'
      get_weight
    ) | shuf -n1)"
    PROGRAM="swww-daemon"
    trans_type="simple"

    # Check if the program is running
    if pgrep "$PROGRAM" >/dev/null; then
      swww img -o $monitor "$BG" --transition-fps 255 --transition-type $trans_type --transition-duration 1
    else
      #swww init && swww img -o $monitor "$BG" --transition-fps 255 --transition-type $trans_type --transition-duration 1
      swww-daemon
    fi
  }

  #set_wallpaper_hyprland
  for ((i = 0; i < ${#monitors[@]}; i++)); do
    set_wallpaper_hyprland_multimonitor ${monitors[i]}
  done
}

case "$1" in
"get-weight")
  get_weight
  ;;
"set-weight")
  echo TODO
  ;;
*)
  # default, change wallpaper
  apply_wallpaper
  ;;
esac
