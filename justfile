# Use zsh for recipes because this repo configures zsh and validation uses zsh.
set shell := ["zsh", "-cu"]

# Top-level Stow packages to use for bulk operations.
# This discovers directories instead of repeating the package list in each recipe.
# .stow-excludes contains top-level dirs that should be skipped, e.g. lazy-nvim.
active_packages := `printf '%s\n' */ | sed 's#/$##' | grep -vxF -f .stow-excludes | sort | tr '\n' ' '`

# Show available recipes by default.
default:
    just --list

# Print packages selected for bulk Stow operations.
packages:
    echo {{active_packages}}

# Install Homebrew dependencies from Brewfile.
install:
    brew bundle

# Update Homebrew metadata, upgrade installed packages/casks, sync Brewfile, and clean up.
update:
    brew update
    brew upgrade
    brew bundle
    brew cleanup

# Preview stowing one package.
preview package:
    stow -nv {{package}}

# Stow one package.
apply package:
    stow {{package}}

# Preview the normal active package set.
preview-all:
    stow -nv {{active_packages}}

# Stow the normal active package set. Use intentionally, mostly for new machines.
apply-all:
    stow {{active_packages}}

# Alias for the setup docs/plan terminology.
stow-all: apply-all

# Unstow one package.
unstow package:
    stow -D {{package}}

# Validate zsh syntax.
check-zsh:
    zsh -n zsh/.zshrc zsh/.zprofile zsh/.zshenv zsh/.config/zsh/*.zsh zsh/.config/zsh/tools/*.zsh

# Preview normal Stow package set.
check-stow: preview-all

# Validate custom Neovim Lua formatting if stylua is available.
check-nvim:
    if command -v stylua >/dev/null 2>&1; then stylua --check nvim/.config/nvim; else echo "stylua not installed; skipping"; fi

# Run all lightweight checks.
check: check-zsh check-stow check-nvim

# Bootstrap an already-stowed machine after Homebrew itself has been installed.
# This installs dependencies and validates. It does not apply Stow links.
bootstrap: install check
