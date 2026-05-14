#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Packages ──────────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew bundle --file "$REPO_DIR/Brewfile"
else
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y zsh tmux git curl unzip ripgrep git-delta
    sudo apt-get install -y fd-find && sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd 2>/dev/null || true
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh tmux git curl unzip ripgrep fd-find git-delta
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y zsh tmux git curl unzip ripgrep
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm zsh tmux git curl unzip ripgrep fd git-delta
  fi

  if ! command -v nvim >/dev/null 2>&1; then
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
      | tar -xz -C /tmp
    sudo mv /tmp/nvim-linux-x86_64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  fi

  if [[ ! -d "$HOME/.antidote" ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  fi

  if ! command -v fnm >/dev/null 2>&1; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$HOME/.local/bin" --skip-shell
  fi

  if ! command -v starship >/dev/null 2>&1; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
  fi

  if ! command -v zoxide >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
fi

# ── Shared symlinks ───────────────────────────────────────────────────────────
bash "$REPO_DIR/install-shared.sh"

# ── Default shell (Linux only) ────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]] && [[ "$SHELL" != "$(command -v zsh)" ]]; then
  ZSH_PATH="$(command -v zsh)"
  grep -q "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
  chsh -s "$ZSH_PATH"
fi

echo "Done. Start a new shell or run: exec zsh"
