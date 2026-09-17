# User executables
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PNPM_HOME="$HOME/.pnpm"
export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE

setopt append_history
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Keybindings
bindkey -e
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[w' kill-region

# Oh My Zsh provides plugin loading and completion initialization. Starship,
# rather than an Oh My Zsh theme, owns the prompt.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git sudo aws kubectl command-not-found)

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  FPATH="${HOMEBREW_PREFIX}/share/zsh-completions:$FPATH"
fi

# Homebrew makes its prefix group-writable by "admin" on purpose, which
# compaudit flags as insecure; skip that check rather than fight brew.
ZSH_DISABLE_COMPFIX=true

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  print -u2 "Oh My Zsh is not installed. Run ./bootstrap.sh from the dotfiles repository."
fi

# Additional completion matching after Oh My Zsh initializes completion.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Additional Homebrew-managed plugins not bundled with Oh My Zsh.
if [[ -r "${HOMEBREW_PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Navigation and search
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Node.js via nvm (installed separately from Homebrew)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Useful aliases; each fallback remains available when an optional tool is absent.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias l='eza --long --icons=auto --group-directories-first'
  alias la='eza --all --icons=auto --group-directories-first'
  alias ll='eza --long --all --header --git --icons=auto --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
  alias tree='eza --tree --icons=auto --group-directories-first'
fi

command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v nvim >/dev/null 2>&1 && alias vim='nvim'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

alias cc='claude'
alias ccd='claude --dangerously-skip-permissions'
alias oc='opencode'
alias h='herdr'

alias dcb='docker compose build'
alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcl='docker compose logs --follow'

# Prompt initialization should remain near the end of the interactive config.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Optional machine-specific settings. Never commit this file.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Syntax highlighting should be sourced after other shell integrations.
if [[ -r "${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
