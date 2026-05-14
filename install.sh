#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"

# ── Package manager detection ────────────────────────────────────────────────
install_pkgs() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "$@"
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y "$@"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "$@"
  else
    echo "Unsupported package manager. Install packages manually: $*" >&2
  fi
}

# ── Packages ─────────────────────────────────────────────────────────────────
install_pkgs zsh tmux git curl unzip ripgrep

# neovim: prefer a recent version via tarball if apt would give us something old
if ! command -v nvim >/dev/null 2>&1; then
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  curl -fsSL "$NVIM_URL" | tar -xz -C /tmp
  sudo mv /tmp/nvim-linux-x86_64 /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
fi

# fd (called fd-find on Debian/Ubuntu — add a shim)
if ! command -v fd >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y fd-find
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd 2>/dev/null || true
  else
    install_pkgs fd
  fi
fi

# ── Antidote ─────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.antidote" ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

# ── Starship prompt ───────────────────────────────────────────────────────────
if ! command -v starship >/dev/null 2>&1; then
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi

# ── zoxide ────────────────────────────────────────────────────────────────────
if ! command -v zoxide >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
backup_and_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(readlink "$target" 2>/dev/null || true)" != "$source" ]]; then
      mv "$target" "$target.$BACKUP_SUFFIX"
    fi
  fi

  ln -sf "$source" "$target"
}

link_file() { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }
link_dir()  { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }

link_file ".zshrc"
link_file ".zsh_plugins.txt"
link_file ".tmux.conf"
link_file ".gitconfig"
link_dir  ".config/nvim"

# Set zsh as default shell if it isn't already
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  ZSH_PATH="$(command -v zsh)"
  if grep -q "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
  else
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
    chsh -s "$ZSH_PATH"
  fi
fi

echo "Done. Start a new shell or run: exec zsh"
