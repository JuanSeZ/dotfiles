# User PATH additions.

typeset -U path PATH

_zsh_path_prepend() {
  local _dir="$1"
  [[ -d "$_dir" ]] && path=("$_dir" $path)
}

_zsh_path_append() {
  local _dir="$1"
  [[ -d "$_dir" ]] && path+=("$_dir")
}

_zsh_path_prepend "$HOME/.local/bin"
_zsh_path_prepend "$HOME/.cargo/bin"
_zsh_path_append "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

unset -f _zsh_path_prepend _zsh_path_append
