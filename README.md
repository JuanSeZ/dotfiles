# Dotfiles

Welcome to my dotfiles repository! This repository contains configuration files and scripts to set up my development environment.

## Installation

The setup process is split into two steps:

### 1. Install Prerequisites

First, install Homebrew and Ansible by running:

```bash
curl -fsSL https://raw.githubusercontent.com/JuanSeZ/dotfiles/main/install.sh | bash
```

### 2. Set Up Your Environment

After installing the prerequisites, set up your environment:

```bash
# Clone this repository
git clone https://github.com/JuanSeZ/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Set up Chezmoi and dotfiles
ansible-playbook playbooks/chezmoi.yml

# Install common tools and applications
ansible-playbook playbooks/common.yml

# Optional: Set up development environments
ansible-playbook playbooks/node.yml    # For Node.js development
ansible-playbook playbooks/java.yml    # For Java development
ansible-playbook playbooks/zsh.yml     # For Zsh configuration
ansible-playbook playbooks/tmux.yml    # For Tmux configuration
ansible-playbook playbooks/macos.yml   # For macOS system configuration
```

## Managing Dotfiles with Chezmoi

After installation, you can manage your dotfiles using Chezmoi:

1. Edit dotfiles:
   ```bash
   chezmoi edit ~/.zshrc
   ```

2. Apply changes:
   ```bash
   chezmoi apply
   ```

3. Update dotfiles:
   ```bash
   chezmoi update
   ```

## Available Playbooks

The installation process uses several Ansible playbooks:

- `common.yml`: Installs basic tools and applications
- `chezmoi.yml`: Sets up Chezmoi for dotfiles management
- `node.yml`: Node.js development environment
- `java.yml`: Java development environment
- `zsh.yml`: Zsh shell configuration
- `tmux.yml`: Tmux configuration
- `macos.yml`: macOS system configuration (Dock, Trackpad, Menubar settings)

## Chezmoi Daily Usage Guide

### Viewing Changes

- Check what files would be changed:
  ```bash
  chezmoi diff
  ```

- See what files Chezmoi is managing:
  ```bash
  chezmoi managed
  ```

### Making Changes

1. **Add a new dotfile**:
   ```bash
   # Add a new file
   chezmoi add ~/.path/to/file

   # Add a new directory
   chezmoi add ~/.path/to/directory
   ```

2. **Edit an existing dotfile**:
   ```bash
   # Edit using your default editor
   chezmoi edit ~/.path/to/file

   # Or edit the source file directly
   chezmoi edit
   ```

3. **Add sensitive data**:
   ```bash
   # Add and encrypt a file
   chezmoi add --encrypt ~/.path/to/sensitive/file
   ```

### Applying Changes

- Apply all changes:
  ```bash
  chezmoi apply
  ```

- Apply changes for a specific file:
  ```bash
  chezmoi apply ~/.path/to/file
  ```

- Apply changes with verbose output:
  ```bash
  chezmoi apply -v
  ```

### Git Operations

- Update your dotfiles:
  ```bash
  chezmoi update
  ```

- Commit changes:
  ```bash
  chezmoi cd
  git add .
  git commit -m "Your commit message"
  git push
  ```

### Useful Commands

- Check Chezmoi's status:
  ```bash
  chezmoi status
  ```

- Verify your dotfiles:
  ```bash
  chezmoi verify
  ```

- Get help:
  ```bash
  chezmoi help
  ```

## Security

- SSH keys and other sensitive data are encrypted using age
- The age key is stored in the macOS Keychain
