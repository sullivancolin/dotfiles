# dotfiles

Personal development environment managed with [chezmoi](https://chezmoi.io). Targets
macOS (primary) and Ubuntu/devcontainers (secondary).

## What's managed

| File | Target |
|---|---|
| `dot_zprofile.tmpl` | `~/.zprofile` |
| `dot_zshrc.tmpl` | `~/.zshrc` |
| `dot_config/zsh/exports.zsh` | `~/.config/zsh/exports.zsh` |
| `dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_gitignore_global` | `~/.gitignore_global` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `dot_hammerspoon/init.lua` | `~/.hammerspoon/init.lua` |
| `dot_config/karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `dot_claude/settings.json` | `~/.claude/settings.json` |
| `iterm2/profile.json` | installed to iTerm2 DynamicProfiles via script |

Shell: **zsh** + [Oh My Zsh](https://ohmyz.sh) + [Starship](https://starship.rs)
Terminal: **iTerm2** · Key remapping: **Karabiner-Elements** · WM automation: **Hammerspoon**

---

## Bootstrap

### macOS (fresh machine)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sullivancolin/dotfiles/main/bootstrap.sh)"
```

This will:
1. Install Xcode CLI tools (if missing)
2. Install Homebrew (if missing)
3. Run `brew bundle` to install all tools and apps from `Brewfile`
4. Set zsh as the default shell
5. Install chezmoi and apply all dotfiles

### Ubuntu / devcontainer

Clone the repo and run:

```bash
git clone https://github.com/sullivancolin/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```

This installs zsh, Oh My Zsh, Starship, uv, just, and core CLI tools, then applies
dotfiles via chezmoi.

---

## How chezmoi works

### The repo IS the source directory

Files in this repo are **not** your live dotfiles — they are the *source of truth*
that chezmoi applies to `$HOME`. The live files (e.g. `~/.zshrc`) are written by
chezmoi from the source files here.

chezmoi state lives in two places:

| Path | Purpose |
|---|---|
| `~/.local/share/chezmoi/` | Source directory (this repo) |
| `~/.config/chezmoi/chezmoi.toml` | Per-machine config (name, email, data) |

### File naming conventions

chezmoi uses a naming scheme to map source files to target paths:

| Source name | What it means | Target |
|---|---|---|
| `dot_zshrc` | leading dot | `~/.zshrc` |
| `dot_config/zsh/aliases.zsh` | directory with dot | `~/.config/zsh/aliases.zsh` |
| `dot_gitconfig.tmpl` | Go template — processed before writing | `~/.gitconfig` |
| `run_onchange_foo.sh` | runs when file content changes | executed (not copied) |

### Template variables

`dot_gitconfig.tmpl` and `dot_zshrc.tmpl` use Go templates. On first `chezmoi init`,
you are prompted for `name` and `email`. These are stored in
`~/.config/chezmoi/chezmoi.toml` and never asked for again.

To update them:

```bash
$EDITOR ~/.config/chezmoi/chezmoi.toml
chezmoi apply
```

OS detection is also available in templates:

```
{{- if eq .chezmoi.os "darwin" }}
# macOS-only config
{{- end }}
```

---

## Day-to-day workflow

### The golden rule

**Never edit `~/.zshrc`, `~/.gitconfig`, or any other managed file directly.**
Changes to `$HOME` files are overwritten on the next `chezmoi apply`.

### Editing a managed file

```bash
chezmoi edit ~/.zshrc          # opens the SOURCE file in $EDITOR
chezmoi apply                  # writes the rendered result to ~/.zshrc
```

Or edit the source file directly in this repo, then apply:

```bash
code-insiders ~/dotfiles/dot_zshrc.tmpl
chezmoi apply
```

### Previewing changes before applying

```bash
chezmoi diff                   # show what would change in $HOME
```

Always run this on an unfamiliar machine before applying.

### Syncing from another machine

```bash
chezmoi update                 # git pull + chezmoi apply in one command
```

Or manually:

```bash
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

### Committing changes

chezmoi edits the source dir — you still need to commit and push:

```bash
cd ~/.local/share/chezmoi      # or: chezmoi cd
git add -p
git commit -m "feat: update zsh aliases"
git push
```

---

## Growing the managed set

### Adding a new CLI tool (no config file)

**macOS** — add to `Brewfile`, then install:

```bash
echo 'brew "neovim"' >> Brewfile
brew bundle
```

**Linux** — add the install command to `scripts/bootstrap-linux.sh`.

### Managing a new tool's config file

1. Configure the tool normally and let it write its config to `$HOME`
2. Hand it to chezmoi:

   ```bash
   chezmoi add ~/.config/neovim/init.lua
   ```

   chezmoi copies it into the source dir as `dot_config/neovim/init.lua` and the
   original file becomes managed (chezmoi owns it from now on).

3. Verify no diff: `chezmoi status` should be clean
4. Commit: `git add dot_config/neovim && git commit -m "feat: add neovim config"`
5. Edit going forward via `chezmoi edit ~/.config/neovim/init.lua`, not directly

### Managing a whole config directory

```bash
chezmoi add ~/.config/ghostty
```

chezmoi adds all files within it recursively.

### Making a config OS-conditional

If a config file needs to differ between macOS and Linux, convert it to a template:

```bash
chezmoi add --template ~/.config/sometool/config
```

Then edit the source file and wrap OS-specific sections:

```
{{- if eq .chezmoi.os "darwin" }}
macos-specific-setting = true
{{- else }}
linux-specific-setting = true
{{- end }}
```

Preview the rendered output before applying:

```bash
chezmoi execute-template < dot_config/sometool/config.tmpl
```

### Stopping management of a file

```bash
chezmoi forget ~/.config/sometool/config
```

The file stays in `$HOME` unchanged — chezmoi just stops tracking it.

---

## iTerm2 profile

The profile is stored in `iterm2/profile.json` and installed to
`~/Library/Application Support/iTerm2/DynamicProfiles/` by a chezmoi
`run_onchange_` script. iTerm2 hot-reloads Dynamic Profiles on change, but a
restart may be needed for new profiles to appear in Preferences.

To update your profile:

1. In iTerm2: **Preferences → Profiles → (select profile) → Other Actions → Copy Profile as JSON**
2. Paste the JSON into `iterm2/profile.json`
3. Run `chezmoi apply` — the install script re-runs automatically because the file hash changed
4. Commit: `git add iterm2/profile.json && git commit -m "chore: update iTerm2 profile"`

---

## What NOT to commit

| File | Reason |
|---|---|
| `~/.claude/settings.local.json` | Machine-specific MCP servers, local permissions |
| Any `.env` file | Secrets |
| Files with absolute local paths | Not portable |
| `~/.local/share/chezmoi/` | That IS this repo — don't nest it |

`settings.local.json` is safe to use for local Claude Code overrides — it merges with
the committed `settings.json` at runtime without being tracked.
