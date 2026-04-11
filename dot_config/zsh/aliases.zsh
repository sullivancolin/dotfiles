# Modern Unix replacements
alias ls="eza --git --icons"
alias ll="eza -la --git --icons"
alias cat="bat"

# fzf with bat preview
alias preview="fzf --preview 'bat --color \"always\" {}'"

# VSCode Insiders
alias code="code-insiders"

# Git shortcuts
alias g="git"
alias gs="git status -sb"
alias gl="git log --oneline --graph --decorate --all"

# uv / Python
alias py="uv run python"
alias pip="uv pip"

# just
alias j="just"
