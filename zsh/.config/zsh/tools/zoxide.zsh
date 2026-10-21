# zoxide shell integration.
# Interactive only: --cmd cd shadows the cd builtin with a fuzzy-matching
# function, so in a script `cd missing-dir` jumps to an unrelated frecent
# directory instead of failing. Same guard fzf.zsh uses.

if [[ -o interactive ]] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi
