# ZSH

```bash
# Стандартная конфигурация
autoload -Uz compinit
compinit
setopt COMPLETE_IN_WORD

# Опции
setopt AUTOCD

# git prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '[%b]'
setopt PROMPT_SUBST
PROMPT='%F{green}${vcs_info_msg_0_}%F{cyan}[%~]%f%f$ '

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

# сокращения для важных каталогов
hash -d NB=~/NetBeansProjects
```
