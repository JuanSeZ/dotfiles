#!/bin/bash

# Import utilities
source ./utils.sh

log_info "Requesting sudo access"
sudo -v
while true
do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done &> /dev/null &
log_success "Sudo access granted"

# Create .zshrc file if it does not exist
if [ ! -f "$HOME/.zshrc" ]; then
    log_info "Creating .zshrc file..."
    touch "$HOME/.zshrc"
    log_success ".zshrc file created!"
else
    log_info ".zshrc file already exists"
fi

# Install Homebrew if not installed
if ! command_exists brew; then
    log_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" & spinner
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log_success "Homebrew installed!"
else
    log_success "Homebrew is already installed"
fi

log_info "Updating Homebrew..."
brew update & spinner
log_success "Homebrew updated!"


# Install XCode Command Line Tools
if ! $(xcode-select --print-path &> /dev/null); then
    log_info "Installing XCode Command Line Tools"
    xcode-select --install &> /dev/null

    until $(xcode-select --print-path &> /dev/null); do
        sleep 5
    done
    log_success "XCode Command Line Tools installed"
else
    log_success "XCode Command Line Tools are already installed"
fi

# Categorize apps by type

communication_apps=(
    "whatsapp"
    "discord"
    "slack"
    "zoom"
)

programming_apps=(
    "visual-studio-code"
    "docker"
    "jetbrains-toolbox"
    "postman"
    "iterm2"
    "figma"
)

entertainment_apps=(
    "spotify"
)

utility_apps=(
    "arc"
    "google-drive"
    "swish"
)

zsh_plugins=(
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
    "zsh-completions"
)

# Install communication apps
log_info "Installing communication apps..."
for app in "${communication_apps[@]}"; do
    if brew list --cask "$app" >/dev/null 2>&1; then
        log_info "$app is already installed"
    else
        log_info "Installing $app..."
        brew install --cask "$app" & spinner
        log_success "$app installed!"
    fi
done

# Install programming apps
log_info "Installing programming apps..."
for app in "${programming_apps[@]}"; do
    if brew list "$app" >/dev/null 2>&1; then
        log_info "$app is already installed"
    else
        log_info "Installing $app..."
        brew install "$app" & spinner
        log_success "$app installed!"
    fi
done

# Install entertainment apps
log_info "Installing entertainment apps..."
for app in "${entertainment_apps[@]}"; do
    if brew list --cask "$app" >/dev/null 2>&1; then
        log_info "$app is already installed"
    else
        log_info "Installing $app..."
        brew install --cask "$app" & spinner
        log_success "$app installed!"
    fi
done

# Install utility apps
log_info "Installing utility apps..."
for app in "${utility_apps[@]}"; do
    if brew list --cask "$app" >/dev/null 2>&1; then
        log_info "$app is already installed"
    else
        log_info "Installing $app..."
        brew install --cask "$app" & spinner
        log_success "$app installed!"
    fi
done

# Install Aerospace
log_info "Installing Aerospace..."
if brew list --cask nikitabobko/tap/aerospace >/dev/null 2>&1; then
    log_info "Aerospace is already installed"
else
    log_info "Installing Aerospace..."
    brew install --cask nikitabobko/tap/aerospace & spinner
    log_success "Aerospace installed!"
fi

log_info "Copying custom Aerospace configuration to home directory..."
cp "./aerospace/dot-aerospace.toml" "$HOME/.aerospace.toml"
log_success "Custom Aerospace configuration copied!"

# Install Nerd Fonts
log_info "Installing Nerd Fonts..."
brew tap homebrew/cask-fonts &> /dev/null
brew install --cask "font-jetbrains-mono" & spinner
log_success "Nerd Fonts installed!"

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh is already installed"
else
    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" & spinner
    log_success "Oh My Zsh installed!"
fi

# Install Zsh plugins
log_info "Installing Zsh plugins..."
for plugin in "${zsh_plugins[@]}"; do
    if ! has_brew "$plugin"; then
        brew_install "$plugin"
        case "$plugin" in
            "zsh-autosuggestions")
                zshrc "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" "zsh-autosuggestions"
                ;;
            "zsh-syntax-highlighting")
                zshrc "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "zsh-syntax-highlighting"
                ;;
        esac
    else
        log_info "$plugin is already installed"
    fi
done

# Install Python
log_info "Installing Python..."
brew_install "pyenv"
if ! has_brew "python"; then
    brew_install "python"
    zshrc 'alias python=/usr/bin/python3' "python config"
    zshrc 'alias pip=/usr/bin/pip3'
    zshrc 'eval "$(pyenv init -)"'
    log_success "Python installed!"
else
    log_info "Python is already installed"
fi

log_info "Installing Python packages..."
pip install --user pipenv &> /dev/null
pip install --upgrade setuptools &> /dev/null
pip install --upgrade pip &> /dev/null
log_success "Python packages installed!"

# Install Node
if ! has_path ".nvm"; then
    log_info "Installing nvm..."
    mkdir -p ~/.nvm
    brew_install "nvm"
    zshrc 'export NVM_DIR="$HOME/.nvm"' "nvm config"
    zshrc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    zshrc '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
    source $(brew --prefix nvm)/nvm.sh
    nvm install node &> /dev/null

    cat >> ~/.zshrc <<'_EOF_'

# nvmrc config
autoload -U add-zsh-hook
load-nvmrc() {
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
        elif [ "$nvmrc_node_version" != "$node_version" ]; then
            nvm use --silent
        fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
        log_info "Reverting to nvm default version"
        nvm use default
    fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
_EOF_

    log_success "nvm installed and configured"
else
    log_success "nvm is already installed"
fi

# Install Java 
log_info "Installing Java..."
if [ ! -d "$HOME/.sdkman" ]; then
    log_info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash &> /dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    zshrc 'export SDKMAN_DIR="$HOME/.sdkman"' "sdkman config"
    zshrc '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"'
    log_success "SDKMAN installed!"
else
    log_info "SDKMAN is already installed"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

log_info "Installing Java via SDKMAN..."
sdk install java &> /dev/null
log_success "Java installed!"

log_info "Installing Maven..."
brew_install "maven"
log_success "Maven installed!"

log_info "Installing Gradle..."
brew_install "gradle"
log_success "Gradle installed!"

# Install Custom Spaceship Prompt
log_info "Installing Custom Spaceship Prompt..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/themes/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
    echo 'ZSH_THEME="spaceship"' >> "$HOME/.zshrc"
    log_success "Custom Spaceship Prompt installed!"
else
    log_info "Custom Spaceship Prompt is already installed"
fi


# Install AstroNnvim
log_info "Installing AstroNvim..."
if [ -d "$HOME/.config/nvim" ]; then
    log_info "AstroNvim is already installed"
else
    log_info "Installing AstroNvim..."
    brew install neovim & spinner
    
    git clone --branch pre-v4 https://github.com/JuanSeZ/neovim-config.git ~/.config/nvim
    git clone --branch main https://github.com/JuanSeZ/neovim-config.git ~/.config/nvim/lua/user
    npm install -g tree-sitter-cli
    brew_install "ripgrep"
    brew_install "lazygit"
    # gdu will be installed as `gdu-go` to avoid conflicts with coreutils
    brew_install "gdu"
    brew_install "bottom"
    log_success "AstroNvim installed!"
fi

# Configure Git credentials
git config --global user.email "juan.zanelli@ing.austral.edu.ar"

log_success "Installation complete!"