# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Environment
export LANG=en_US.UTF-8
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"

# Antidote — prefer Homebrew (macOS), fall back to cloned copy (Linux)
if [[ -r "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" ]]; then
  source "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh"
elif [[ -r "$HOME/.antidote/antidote.zsh" ]]; then
  source "$HOME/.antidote/antidote.zsh"
fi
antidote load "$HOME/.zsh_plugins.txt" 2>/dev/null || true

# Aliases
alias vi='nvim'
alias vim='nvim'
alias ll='ls -lah'
alias hg='history | grep'

# zoxide (smart cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Starship prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Local overrides (tokens, work-specific paths, etc.)
[[ -f "$HOME/.zsh_local" ]] && source "$HOME/.zsh_local"
