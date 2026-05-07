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

# Seed git identity env vars for non-interactive chezmoi templating.
# promptStringOnce requires /dev/tty; these let the template skip the prompt
# in devcontainers/CI. Falls through to interactive prompt if both are unset.
[[ -z "${GIT_AUTHOR_NAME:-}"  ]] && GIT_AUTHOR_NAME="$(git config --global user.name  2>/dev/null || true)"
[[ -z "${GIT_AUTHOR_EMAIL:-}" ]] && GIT_AUTHOR_EMAIL="$(git config --global user.email 2>/dev/null || true)"
export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL

# Apply dotfiles (idempotent)
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  echo "Applying dotfiles..."
  chezmoi apply
elif [ -d "$DOTFILES_DIR/.git" ]; then
  echo "Initialising chezmoi from local source $DOTFILES_DIR..."
  chezmoi init --apply --source "$DOTFILES_DIR"
else
  echo "Initialising chezmoi from https://github.com/sullivancolin/dotfiles.git..."
  chezmoi init --apply https://github.com/sullivancolin/dotfiles.git
fi

echo "Done."
