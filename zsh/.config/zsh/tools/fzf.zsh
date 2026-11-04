# fzf configuration and shell integration.

# OneDark Cool, the theme across the dotfiles (Ghostty's palette)
export FZF_DEFAULT_OPTS="\
--color=bg+:#3e4452,bg:#242b38,spinner:#56b6c2,hl:#e06c75 \
--color=fg:#abb2bf,header:#e06c75,info:#c678dd,pointer:#61afef \
--color=marker:#98c379,fg+:#ffffff,prompt:#c678dd,hl+:#e06c75 \
--color=selected-bg:#3e4452 \
--multi"

# bat has no OneDark Cool; OneHalfDark is the closest, as for delta in lazygit
export BAT_THEME="OneHalfDark"

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
