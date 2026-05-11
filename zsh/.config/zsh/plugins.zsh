# Oh My Zsh setup.

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Starship initializes the prompt later, so avoid loading an Oh My Zsh theme
# unless ZSH_THEME is explicitly provided by the environment.
ZSH_THEME="${ZSH_THEME:-}"

plugins=(git kubectl)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi
