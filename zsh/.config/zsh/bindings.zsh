# Shell key bindings.

# ctrl+f: tmux-sessionizer inside tmux (or outside both), rex-sessionizer inside Rex.
if [[ -z ${TMUX:-} && -n ${REX_SESSION:-} ]] && command -v rex-sessionizer >/dev/null 2>&1; then
  # A widget, not typed input: it opens the popup without touching history
  _rex_sessionizer() { rex-sessionizer >/dev/null 2>&1 }
  zle -N _rex_sessionizer
  bindkey '^f' _rex_sessionizer
elif command -v tmux-sessionizer >/dev/null 2>&1; then
  bindkey -s '^f' "tmux-sessionizer\n"
fi
