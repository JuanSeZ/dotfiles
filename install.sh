#!/bin/bash

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${CYAN}INFO: $1${NC}"
}

log_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is only for macOS"
    exit 1
fi

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log_success "Homebrew installed"
else
    log_info "Homebrew already installed"
fi

# Install Ansible if not installed
if ! command -v ansible &> /dev/null; then
    log_info "Installing Ansible..."
    brew install ansible
    log_success "Ansible installed"
else
    log_info "Ansible already installed"
fi

log_success "Prerequisites installation complete! 🎉"
log_info "You can now clone the dotfiles repository and run the Ansible playbooks."
log_info "Run the following commands:"
log_info "  1. git clone https://github.com/yourusername/dotfiles.git ~/dotfiles"
log_info "  2. cd ~/dotfiles"
log_info "  3. ansible-playbook playbooks/chezmoi.yml"
log_info "  4. ansible-playbook playbooks/common.yml" 