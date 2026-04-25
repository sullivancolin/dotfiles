#!/usr/bin/env bash
# Linux / devcontainer bootstrap — called by bootstrap.sh
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Use sudo only when not already root (bare Ubuntu containers run as root)
if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "Updating apt..."
$SUDO apt-get update -qq

# Core tools
echo "Installing core tools..."
$SUDO apt-get install -y -qq \
  zsh \
  git \
  curl \
  wget \
  jq \
  ripgrep \
  fd-find \
  unzip

# Detect architecture for GitHub release downloads
ARCH="$(uname -m)"
DEB_ARCH="$(dpkg --print-architecture)"   # amd64 or arm64

# bat — apt version is often stale, install from GitHub releases
if ! command -v bat &>/dev/null; then
  echo "Installing bat..."
  BAT_VERSION="$(curl -sI https://github.com/sharkdp/bat/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '[:space:]')"
  curl -sLO "https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${DEB_ARCH}.deb"
  $SUDO dpkg -i "bat_${BAT_VERSION}_${DEB_ARCH}.deb"
  rm "bat_${BAT_VERSION}_${DEB_ARCH}.deb"
fi

# eza — not in apt, install from GitHub releases
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  EZA_VERSION="$(curl -sI https://github.com/eza-community/eza/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '[:space:]')"
  case "$ARCH" in
    x86_64)  EZA_ARCH="x86_64-unknown-linux-gnu" ;;
    aarch64) EZA_ARCH="aarch64-unknown-linux-gnu" ;;
    *)       echo "Unsupported arch for eza: $ARCH" && exit 1 ;;
  esac
  curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz" | \
    $SUDO tar -xz -C /usr/local/bin
fi

# fzf — apt version in Ubuntu 22.04 is too old (v0.29); install from GitHub releases
if ! command -v fzf &>/dev/null; then
  echo "Installing fzf..."
  FZF_VERSION="$(curl -sI https://github.com/junegunn/fzf/releases/latest | grep -i location | sed 's/.*tag\/v//' | tr -d '[:space:]')"
  case "$ARCH" in
    x86_64)  FZF_ARCH="linux_amd64" ;;
    aarch64) FZF_ARCH="linux_arm64" ;;
    *)       echo "Unsupported arch for fzf: $ARCH" && exit 1 ;;
  esac
  curl -sL "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-${FZF_ARCH}.tar.gz" | \
    $SUDO tar -xz -C /usr/local/bin
fi

# zsh-autosuggestions + zsh-syntax-highlighting
$SUDO apt-get install -y -qq zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null || \
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
export PATH="$HOME/.local/bin:$PATH"

# uv tools
echo "Installing uv tools..."
while IFS= read -r tool || [[ -n "$tool" ]]; do
  [[ -z "$tool" || "$tool" == \#* ]] && continue
  uv tool install "$tool"
done < "$DOTFILES_DIR/uv-tools"

# just
if ! command -v just &>/dev/null; then
  echo "Installing just..."
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | \
    bash -s -- --to "$HOME/.local/bin"
fi

# Ensure ~/.ssh exists (required by oh-my-zsh ssh-agent plugin)
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Set zsh as default shell
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting zsh as default shell..."
  chsh -s "$ZSH_PATH" || $SUDO chsh -s "$ZSH_PATH" "$USER"
fi
