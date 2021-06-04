# variables
export TERM=st-256color
export EDITOR=vim
export BROWSER=firefox-bin
export PATH=$HOME/.local/bin:$PATH

# history
HISTFILE=~/.zsh/zhistory
HISTSIZE=10000
SAVEHIST=10000

# zsh Settings 
autoload -U colors && colors
autoload -U compinit  vcs_info 
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

# git settings
git_branch_test_color() {
  local ref=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [ -n "${ref}" ]; then
    if [ -n "$(git status --porcelain)" ]; then
      local gitstatuscolor='%F{red}**M**'
    else
      local gitstatuscolor='%F{green}'
    fi
    echo "${gitstatuscolor} (${ref})"
  else
    echo ""
  fi
}

# prompt
setopt prompt_subst
PROMPT='%F{#FFFF00}%n@%F{#5C5CFF}%m:%15<..<%~%<<$(git_branch_test_color)%F{none}%# '

# plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source ~/.zsh/.fzf/shell/completion.zsh 2> /dev/null
source ~/.zsh/.fzf/shell/key-bindings.zsh 2> /dev/null

if [[ ! "$PATH" == *~/.zsh/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/$HOME/.zsh/.fzf/bin"
fi

# autocompletion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ls - colors
export CLICOLOR=1
ls --color=auto &> /dev/null 

# aliases
alias pw='bash -c '"'"'echo `tr -dc $([ $# -gt 1 ] && echo $2 || echo "A-Za-z0-9") < /dev/urandom | head -c $([ $# -gt 0 ] && echo $1 || echo 30)`'"'"' --'
alias ew='doas emerge -avuDN --keep-going --with-bdeps=y @world'
alias pa='doas vim /etc/portage/package.accept_keywords'
alias dc='doas emerge -p --changed-deps --deep @world '
alias e='doas env-update && source /etc/profile'
alias pm='doas vim /etc/portage/package.mask'
alias ap='doas ls /var/db/pkg/* > pkglist.txt'
alias pu='doas vim /etc/portage/package.use'
alias c='git commit -m "changes in dotfiles"'
alias pr='doas vim /etc/portage/repos.conf'
alias sf='doas emerge --resume --skipfirst'
alias mk='doas vim /etc/portage/make.conf'
alias build='doas make clean install'
alias w='cat /var/lib/portage/world'
alias sd='emerge --searchdesc'
alias lu='ls -l /dev/disk/by-uuid'
alias en='doas emerge --noreplace'
alias mf='fc-list | grep ".local"'
alias af='fc-list | grep "fonts"'
alias sc='doas rm -rf ~/.cache/*'
alias dc='doas emerge --depclean'
alias de='doas emerge --deselect'
alias ep='doas emerge --prune'
alias ec='doas emerge --clean'
alias ds='doas eclean-dist -d'
alias pc='perl-cleaner --all'
alias es='doas emerge --sync'
alias r='doas chmod -R 777'
alias er='doas emerge -cav'
alias eu='doas etc-update'
alias ls='ls --color=auto'
alias x='doas chmod +x *'
alias 1s='doas emerge -1'
alias ll='doas layman -L'
alias la='doas layman -a'
alias ld='doas layman -d'
alias ei='emerge --info'
alias ss='doas spacefm'
alias dg='doas geany'
alias t='doas touch'
alias ef='emerge -s'
alias cc='ccache -s'
alias v='doas vim'
alias ex='tar -xpvf'
alias co='tar -zcvf'
alias u='git add -u'
alias s='git status'
alias gc='git clone'
alias l='doas ln -s'
alias p='git push'
alias a='git add'
alias un='unzip'
alias d='doas '

