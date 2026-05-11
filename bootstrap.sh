#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_dir"

if ! command -v brew >/dev/null 2>&1; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
fi

if ! command -v brew >/dev/null 2>&1; then
  cat <<'EOF'
Homebrew is not installed or is not on PATH.

Install Homebrew first, then re-run this script:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

After installation, follow Homebrew's shellenv instructions if needed.
EOF
  exit 1
fi

brew bundle --file "$repo_dir/Brewfile"

if ! command -v just >/dev/null 2>&1; then
  echo "just was not installed successfully or is not on PATH."
  exit 1
fi

just check

cat <<'EOF'

Bootstrap complete.

This script does not apply Stow symlinks automatically.
Preview first:
  just preview-all

Apply when ready:
  just apply-all
EOF
