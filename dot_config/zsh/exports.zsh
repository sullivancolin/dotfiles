# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Editor: VSCode Insiders locally, vim over SSH
if [[ -n "${SSH_CONNECTION:-}" ]]; then
  export EDITOR="vim"
  export VISUAL="vim"
else
  export EDITOR="code-insiders --wait"
  export VISUAL="code-insiders --wait"
fi

# npm user-local globals (set by bootstrap; avoids root-owned installs in containers)
export PATH="$HOME/.npm-global/bin:$PATH"

# bat
export BAT_THEME="TwoDark"
export BAT_STYLE="full,changes"
