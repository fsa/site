# default config
autoload -Uz compinit
compinit
setopt COMPLETE_IN_WORD
setopt AUTOCD

# history
HISTFILE=$HOME/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# plugins
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [ -f $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# prompt
git_status_symbol() {
  if git rev-parse --is-inside-work-tree &> /dev/null; then
    if ! git diff --quiet &> /dev/null; then
      echo "%F{red}*%f"
    fi
  fi
}
user_host_ssh() {
  if [[ -n "$SSH_CONNECTION" || -n "$SUDO_USER" ]]; then
    echo '%F{red}%n@%m%f:'
  fi
}
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'
setopt PROMPT_SUBST
PROMPT='$(user_host_ssh)$(git_status_symbol)%F{green}${vcs_info_msg_0_}%F{cyan}[%~]%f%(#.#.$) '


# git aliases
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'
alias gca='git commit --verbose --all'
alias gca!='git commit --verbose --all --amend'
alias glog='git log --oneline --decorate --graph'
function gpa() {
    for server in $(git remote -v | cut -f1 | uniq) ; do
        echo "git push $server"; git push $server
    done
}
function gpat() {
    for server in $(git remote -v | cut -f1 | uniq) ; do
        echo "git push $server --tags"; git push $server --tags
    done
}
alias gst='git status'

# vscode aliases
function vsc {
  if (( $# )); then
    code $@
  else
    code .
  fi
}


# hashes
hash -d www=/var/www
