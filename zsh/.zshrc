# Modular zsh entrypoint.
# Most setup lives under ~/.config/zsh/ so it can be stowed cleanly.

_zsh_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

for _zsh_file in \
  "$_zsh_config_dir/plugins.zsh" \
  "$_zsh_config_dir/env.zsh" \
  "$_zsh_config_dir/path.zsh" \
  "$_zsh_config_dir/bindings.zsh"; do
  [[ -r "$_zsh_file" ]] && source "$_zsh_file"
done

for _zsh_tool in fzf zoxide pyenv starship; do
  _zsh_file="$_zsh_config_dir/tools/${_zsh_tool}.zsh"
  [[ -r "$_zsh_file" ]] && source "$_zsh_file"
done

_zsh_file="$_zsh_config_dir/local.zsh"
[[ -r "$_zsh_file" ]] && source "$_zsh_file"

unset _zsh_config_dir _zsh_file _zsh_tool
