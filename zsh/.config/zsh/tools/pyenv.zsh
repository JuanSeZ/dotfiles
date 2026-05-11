# pyenv shell integration.

export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [[ -d "$PYENV_ROOT/bin" ]]; then
  typeset -U path PATH
  path=("$PYENV_ROOT/bin" $path)
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi
