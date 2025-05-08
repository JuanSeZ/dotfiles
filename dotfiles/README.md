# Dotfiles

My personal dotfiles managed with Chezmoi.

## Setup

1. Install Chezmoi:
   ```bash
   brew install chezmoi
   ```

2. Initialize the repository:
   ```bash
   chezmoi init --apply https://github.com/zanelli38/dotfiles.git
   ```

3. Set up age encryption:
   ```bash
   # Install age
   brew install age

   # Generate age key
   age-keygen -o ~/.config/chezmoi/age_key.txt

   # Store in macOS Keychain
   security add-generic-password -a $USER -s chezmoi-age-key -w "$(cat ~/.config/chezmoi/age_key.txt)"
   ```

## Daily Usage

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

## Directory Structure

- `dot_config/`: XDG-compliant configuration files
- `dot_ssh/`: SSH configuration and keys (encrypted)
- `dot_tmux/`: Tmux configuration
- `dot_zsh/`: Zsh configuration

## Security

- SSH keys and other sensitive data are encrypted using age
- The age key is stored in the macOS Keychain
- Chezmoi automatically retrieves the key when needed

## Troubleshooting

If you encounter issues:

1. Check Chezmoi's status:
   ```bash
   chezmoi doctor
   ```

2. Verify your age key is accessible:
   ```bash
   security find-generic-password -a $USER -s chezmoi-age-key -w
   ```

3. Check file permissions:
   ```bash
   ls -la ~/.config/chezmoi/
   ``` 