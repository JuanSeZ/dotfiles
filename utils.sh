#!/bin/bash

# Utilities for logging and command existence check
source ./logger.sh

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a brew package
brew_install() {
    log_info "Installing $1..."
    brew install "$1" & spinner
    log_success "$1 installed!"
}

# Function to add a line to .zshrc if it doesn't already exist
zshrc() {
    if ! grep -Fxq "$1" ~/.zshrc; then
        echo "$1" >> ~/.zshrc
        log_info "$2 added to .zshrc"
    fi
}

# Check if a Homebrew package is installed
has_brew() {
    brew list "$1" >/dev/null 2>&1
}

has_path() {
  local path="$@"
  if [ -e "$HOME/$path" ]; then
    return 0
  fi
  return 1
}
