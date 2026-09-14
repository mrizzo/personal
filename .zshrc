# --- Basics ---
export SHELL=/bin/zsh
export EDITOR=vim
export VISUAL=vim
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# --- Paths ---
export PATH="/opt/homebrew/bin:$HOME/bin:/usr/local/bin:/Users/mrizzo/.local/bin:$PATH"

# --- Prompt (using git status) ---
autoload -Uz vcs_info
precmd() { vcs_info }
setopt prompt_subst
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f ${vcs_info_msg_0_}%# '

# --- Host specific ---
case "$(hostname -s)" in
  magatsukami)
    [ -f /usr/local/share/google-cloud-sdk/path.zsh.inc ] && source /usr/local/share/google-cloud-sdk/path.zsh.inc
    ;;
esac

# Enable git info
zstyle ':vcs_info:git:*' formats '(%b)'

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
bindkey '^R' history-incremental-search-backward

# --- Completion ---
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=**'

# --- Aliases ---
alias ll='ls -lah'
alias gs='git status'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias mbrew="arch -arm64e /opt/homebrew/bin/brew" # arm64e homebrew path (m1   )
alias ibrew="arch -x86_64 /usr/local/bin/brew"    # x86_64 homebrew path (intel)
alias greenfield='cd /Users/mrizzo/code/greenfield && source config && .venv/bin/python greenfield.py'
alias msgsearch='/usr/bin/python3 /Users/mrizzo/code/message-search/msgsearch.py'
alias healthfocus='python3 /Users/mrizzo/code/health-focus/health_focus.py'

# verified move — mvchck SOURCE DEST  (backup-tools)
source ~/code/backup-tools/mvchck.sh 2>/dev/null || true
alias jkmv='mvchck'   # Jawed Karim mv


# --- Plugins (optional) ---
# If using oh-my-zsh:
# export ZSH="$HOME/.oh-my-zsh"
# plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
# source $ZSH/oh-my-zsh.sh

# If not using oh-my-zsh:
# zsh-autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null || true
# zsh-syntax-highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null || true

# --- Misc ---
setopt AUTO_CD        # just type dir name to cd
setopt CORRECT        # autocorrect commands
setopt NO_BEEP

# --- Custom Functions ---
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xvjf "$1"   ;;
      *.tar.gz)    tar xvzf "$1"   ;;
      *.tar.xz)    tar xvJf "$1"   ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xvf "$1"    ;;
      *.tbz2)      tar xvjf "$1"   ;;
      *.tgz)       tar xvzf "$1"   ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "Don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# --- shithub                   ---
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias gb="git branch"
alias gco="git checkout"
alias gnb="git checkout -b"
alias glog="git log --oneline --graph --decorate"
alias glast="git show --stat HEAD"
alias gunstage="git reset HEAD"
alias gnuke="git checkout -- ."

gmerge() {
  branch=$(git branch --show-current)
  git checkout main
  git pull
  git merge "$branch"
  git push
  git branch -d "$branch"
}
gmove() {
  # uncommitted changes on main → move them to a new branch
  branch="${1:?usage: gmove <branch-name>}"
  git stash
  git checkout -b "$branch"
  git stash pop
}
gsave() {
  # already committed to main → rescue commits onto a branch, reset main
  branch="${1:?usage: gsave <branch-name>}"
  git checkout -b "$branch"
  git checkout main
  git reset --hard origin/main
  git checkout "$branch"
}
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias update-claude='sudo rm -f /usr/local/bin/claude && npm i -g @anthropic-ai/claude-code'

if [[ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" == "1" ]]; then
  print -P "%F{red}⚠ shell is running under Rosetta (x86_64)%f"
fi
