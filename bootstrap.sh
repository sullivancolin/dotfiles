#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OS="$(uname -s)"

case "$OS" in
  Darwin) source "$DOTFILES_DIR/scripts/bootstrap-macos.sh" ;;
  Linux)  source "$DOTFILES_DIR/scripts/bootstrap-linux.sh" ;;
  *)      echo "Unsupported OS: $OS" && exit 1 ;;
esac

# Install chezmoi if not present
if ! command -v chezmoi &>/dev/null; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Apply dotfiles (idempotent)
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "Applying dotfiles..."
  chezmoi apply
else
  echo "Initialising chezmoi from gh:sullivancolin/dotfiles..."
  chezmoi init --apply gh:sullivancolin/dotfiles
fi

echo "Done."
