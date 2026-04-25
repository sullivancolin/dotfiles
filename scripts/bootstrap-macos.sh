#!/usr/bin/env bash
# macOS bootstrap — called by bootstrap.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode CLI tools..."
  xcode-select --install
  echo "Re-run bootstrap.sh after Xcode CLI tools finish installing."
  exit 1
fi

# Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# uv
if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Install all packages from Brewfile
echo "Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# uv tools
echo "Installing uv tools..."
while IFS= read -r tool || [[ -n "$tool" ]]; do
  [[ -z "$tool" || "$tool" == \#* ]] && continue
  uv tool install "$tool"
done < "$DOTFILES_DIR/uv-tools"

# Set zsh as default shell if not already
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting zsh as default shell..."
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
fi
