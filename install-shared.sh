#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"

backup_and_link() {
  local source="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(readlink "$target" 2>/dev/null || true)" == "$source" ]]; then
      echo "  already linked $target"
      return
    fi
    echo "  backing up $target → $target.$BACKUP_SUFFIX"
    mv "$target" "$target.$BACKUP_SUFFIX"
  fi
  ln -sf "$source" "$target"
  echo "  linked $target"
}

link_file() { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }
link_dir()  { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }

link_file ".config/starship.toml"
link_file ".zshrc"
link_file ".zsh_plugins.txt"
link_file ".tmux.conf"
link_file ".gitconfig"
link_dir  ".config/nvim"

# Download/update zsh plugins. antidote is a zsh function (not a binary), so
# source it inside a zsh subshell before calling.
zsh -c '
  if [[ -r "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh" ]]; then
    source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
  elif [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
    source "$HOME/.antidote/antidote.zsh"
  fi
  antidote update
' || true
