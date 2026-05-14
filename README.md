# dotfiles

Shared config for any machine (Mac or Linux). Managed via symlinks so edits in the repo are live immediately.

## What's included

| File | Purpose |
|---|---|
| `.zshrc` | Shell config (antidote, starship, zoxide, fnm) |
| `.zsh_plugins.txt` | Zsh plugins via antidote |
| `.tmux.conf` | Tmux with vi mode, mouse, TPM |
| `.gitconfig` | Git config with delta as pager |
| `.config/nvim/` | Neovim with lazy.nvim |
| `.config/starship.toml` | Minimal starship prompt |

## Setup on a new machine

```sh
git clone git@github.com:Asing1001/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
bash install.sh
```

`install.sh` detects the OS, installs packages (Homebrew on Mac, apt/dnf/pacman on Linux), then symlinks all config files into `~`.

## Machine-specific config

Anything machine-specific (tokens, aliases, local tools) goes in `~/.zsh_local` — sourced at the end of `.zshrc` but never committed.

```sh
# ~/.zsh_local example
export SOME_API_KEY="..."
alias work="cd ~/work/myproject"
```

## MacBook setup

The MacBook has its own repo ([Mac-Configs](https://github.com/Asing1001/Mac-Configs)) for Mac-specific apps and settings. Its `install.sh` clones this repo and runs `install-shared.sh` to get the shared configs, then adds Mac-specific things on top.

## Day-to-day

- **Change shared config** (zsh, tmux, nvim) → edit in `~/projects/dotfiles`, commit, push. Other machines pick it up with `git pull`.
- **Add a new machine** → clone repo, run `bash install.sh`.
- **Machine-specific tweaks** → `~/.zsh_local`, never committed.
