# Shared interactive/session environment.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export MANPAGER="${MANPAGER:-sh -c 'col -bx | bat -l man -p'}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
