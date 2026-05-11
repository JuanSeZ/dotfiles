# fzf configuration and shell integration.

export FZF_DEFAULT_OPTS="\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

_fzf_prefixes=()
[[ -n "$HOMEBREW_PREFIX" ]] && _fzf_prefixes+=("$HOMEBREW_PREFIX")

if command -v brew >/dev/null 2>&1; then
  _fzf_brew_prefix="$(brew --prefix 2>/dev/null)"
  [[ -n "$_fzf_brew_prefix" ]] && _fzf_prefixes+=("$_fzf_brew_prefix")
fi

_fzf_prefixes+=(/opt/homebrew /usr/local)

if [[ -o interactive && -o zle && -t 0 && -t 1 ]]; then
  for _fzf_prefix in "${_fzf_prefixes[@]}"; do
    _fzf_shell_dir="$_fzf_prefix/opt/fzf/shell"

    if [[ -r "$_fzf_shell_dir/key-bindings.zsh" || -r "$_fzf_shell_dir/completion.zsh" ]]; then
      [[ -r "$_fzf_shell_dir/key-bindings.zsh" ]] && source "$_fzf_shell_dir/key-bindings.zsh"
      [[ -r "$_fzf_shell_dir/completion.zsh" ]] && source "$_fzf_shell_dir/completion.zsh"
      break
    fi
  done
fi

unset _fzf_prefixes _fzf_prefix _fzf_brew_prefix _fzf_shell_dir
