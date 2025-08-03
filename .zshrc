eval "$(/opt/homebrew/bin/brew shellenv)"

# bun completions
[ -s "/Users/subhan/.bun/_bun" ] && source "/Users/subhan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# starship

# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
export STARSHIP_CONFIG=~/.config/starship/starship.toml
type starship_zle-keymap-select >/dev/null || \
  {
    eval "$(starship init zsh)"
  }

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export EDITOR=/opt/homebrew/bin/nvim

# Eza
alias ls="eza --icons --git -a"
alias ld="eza --tree --level=2 --icons --git"

# Others
alias cl="clear"
alias pn="pnpm"
alias pb="pnpm run build"
alias ps="pnpm start"

alias cd="z"

# Bind key to open a new session
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions
bindkey -v

if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zi/bin/zi.zsh"


autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
# examples here -> https://wiki.zshell.dev/ecosystem/category/-annexes
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands
zinit snippet OMZP::git
zinit snippet OMZP::brew
zinit snippet OMZP::direnv
zinit snippet OMZP::fzf

# fzf
source <(fzf --zsh)

# pnpm
export PNPM_HOME="/Users/subhan/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"  

# Created by `pipx` on 2025-01-19 18:00:36
export PATH="$PATH:/Users/subhan/.local/bin"
export SNAP_HAPPY_SCREENSHOT_PATH="~/Pictures/snaphappy"

alias claude="/Users/subhan/.claude/local/claude"
alias clr="claude --resume" # Pick and resume session
alias clc="claude --continue" # Continue last session
alias cls="claude --dangerously-skip-permissions"

alias gtw="git-tmux-workspace"

export PATH="$(go env GOPATH)/bin:$PATH"
