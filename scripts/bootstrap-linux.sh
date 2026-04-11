#!/usr/bin/env bash
# Linux / devcontainer bootstrap — called by bootstrap.sh
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "Updating apt..."
sudo apt-get update -qq

# Core tools
echo "Installing core tools..."
sudo apt-get install -y -qq \
  zsh \
  git \
  curl \
  wget \
  jq \
  ripgrep \
  fd-find \
  fzf \
  unzip

# bat — apt version is often stale, install from GitHub releases
if ! command -v bat &>/dev/null; then
  echo "Installing bat..."
  BAT_VERSION="$(curl -sI https://github.com/sharkdp/bat/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '[:space:]')"
  curl -sLO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb"
  sudo dpkg -i "bat_${BAT_VERSION}_amd64.deb"
  rm "bat_${BAT_VERSION}_amd64.deb"
fi

# eza — not in apt, install from GitHub releases
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  EZA_VERSION="$(curl -sI https://github.com/eza-community/eza/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '[:space:]')"
  curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" | \
    sudo tar -xz -C /usr/local/bin
fi

# zsh-autosuggestions + zsh-syntax-highlighting
sudo apt-get install -y -qq zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null || \
  echo "Note: zsh-autosuggestions/zsh-syntax-highlighting not in apt — will source from oh-my-zsh plugins"

# Oh My Zsh (unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Starship
if ! command -v starship &>/dev/null; then
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# uv
if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# just
if ! command -v just &>/dev/null; then
  echo "Installing just..."
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | \
    bash -s -- --to "$HOME/.local/bin"
fi

# Set zsh as default shell
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting zsh as default shell..."
  chsh -s "$ZSH_PATH" || sudo chsh -s "$ZSH_PATH" "$USER"
fi
