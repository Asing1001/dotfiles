#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"

# ── Packages ──────────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Set up brew in PATH for this script
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew install neovim tmux git ripgrep fd antidote starship zoxide
else
  # Linux: detect package manager
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y zsh tmux git curl unzip ripgrep
    # fd is called fd-find on Debian/Ubuntu
    sudo apt-get install -y fd-find && sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd 2>/dev/null || true
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh tmux git curl unzip ripgrep fd-find
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y zsh tmux git curl unzip ripgrep
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm zsh tmux git curl unzip ripgrep fd
  fi

  # neovim: install from tarball to avoid stale distro versions
  if ! command -v nvim >/dev/null 2>&1; then
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
      | tar -xz -C /tmp
    sudo mv /tmp/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  fi

  # antidote
  if [[ ! -d "$HOME/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  fi

  # starship
  if ! command -v starship >/dev/null 2>&1; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  fi

  # zoxide
  if ! command -v zoxide >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
fi

# ── Symlinks ──────────────────────────────────────────────────────────────────
backup_and_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$(readlink "$target" 2>/dev/null || true)" != "$source" ]]; then
      echo "  backing up $target → $target.$BACKUP_SUFFIX"
      mv "$target" "$target.$BACKUP_SUFFIX"
    fi
  fi

  ln -sf "$source" "$target"
  echo "  linked $target"
}

link_file() { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }
link_dir()  { backup_and_link "$REPO_DIR/home/$1" "$HOME/$1"; }

link_file ".zshrc"
link_file ".zsh_plugins.txt"
link_file ".tmux.conf"
link_file ".gitconfig"
link_dir  ".config/nvim"

# ── Default shell (Linux only — macOS users set this in System Preferences) ──
if [[ "$(uname)" != "Darwin" ]] && [[ "$SHELL" != "$(command -v zsh)" ]]; then
  ZSH_PATH="$(command -v zsh)"
  grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
  chsh -s "$ZSH_PATH"
fi

echo "Done. Start a new shell or run: exec zsh"
