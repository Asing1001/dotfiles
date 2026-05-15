# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Homebrew (macOS)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Environment
export LANG=en_US.UTF-8
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"

# vi-mode cursor shape (block in normal, beam in insert)
VI_MODE_SET_CURSOR=true

# Antidote — Homebrew (macOS) or cloned (Linux)
if [[ -r "${HOMEBREW_PREFIX:-}/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh"
elif [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi
antidote load "$HOME/.zsh_plugins.txt" 2>/dev/null || true

# Aliases
alias vi='nvim'
alias vim='nvim'
alias la='ls -lAh'

# Tools
command -v fnm     >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"
command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Local overrides (machine-specific, not in git)
[[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"
