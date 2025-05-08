#!/usr/bin/env bash

# This file should be located in usr/local/bin/
session=$(find ~ ~/sandbox ~/sirius/debbie ~/sirius/patagonia ~/university/lab3/zelmira ~/personal -mindepth 1 -maxdepth 1 -type d | fzf)
session_name=$(basename "$session" | tr . _)

if ! tmux has_session -t "$session_name" 2> /dev/null; then
    tmux new-session -s "$session_name" -c "$session" -d 
fi

tmux switch-client -t "$session_name"

