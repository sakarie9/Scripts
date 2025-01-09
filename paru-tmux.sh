#!/usr/bin/env bash

export SHELL=/bin/fish

session_name="paru"
cmd="paru -Syu; pkill -SIGRTMIN+8 waybar"

# 检查是否存在的tmux session
if tmux has-session -t $session_name 2>/dev/null; then
  # 检查是否在tmux内
  if [ -n "$TMUX" ]; then
    # 在 tmux 内
    bash -c "$cmd"
  else
    # 不在 tmux 内，则连接到此session并运行命令
    tmux send-keys -t $session_name "$cmd" Enter
    tmux attach-session -t $session_name
  fi
else
  # 如果不存在，则新建session并运行命令
  # tmux new-session -s $session_name "fish --command ${cmd}"
  tmux new-session -s $session_name -d
  tmux send-keys -t $session_name "$cmd" Enter
  tmux attach-session -t $session_name
fi
