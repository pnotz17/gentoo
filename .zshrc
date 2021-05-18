#  Basics 
autoload -U colors && colors
autoload -U compinit  vcs_info 
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION

# Environment variables
export TERM=st-256color
export EDITOR=nvim
export BROWSER=firefox-bin
export PATH=$HOME/.local/bin:$PATH

# History
HISTFILE=~/.zsh/zhistory
HISTSIZE=10000
SAVEHIST=10000

# Prompt
setopt prompt_subst
PROMPT='%F{none}%n@%F{#FF00FF}%m:%15<..<%~%<<$(git_branch_test_color)%F{none}%# '

# Git settings
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

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source ~/.zsh/.fzf/shell/completion.zsh 2> /dev/null
source ~/.zsh/.fzf/shell/key-bindings.zsh 2> /dev/null

if [[ ! "$PATH" == *~/.zsh/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/$HOME/.zsh/.fzf/bin"
fi

# Autocompletion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ls - colors
export CLICOLOR=1
ls --color=auto &> /dev/null && alias ls='ls --color=auto'

# Aliases
alias d='doas '
alias v='doas nvim'
alias ss='doas spacefm'
alias build='doas make clean install'
alias sc='doas rm -rf ~/.cache/*'
alias un='unzip'
alias ex='tar -xpvf'
alias co='tar -zcvf'
alias u='git add -u'
alias s='git status'
alias a='git add'
alias c='git commit -m "changes in dotfiles"'
alias p='git push'
alias gc='git clone'
alias x='doas chmod +x *'
alias af='fc-list | grep "fonts"'
alias mf='fc-list | grep ".local"'
alias l='doas ln -s'
alias lu='ls -l /dev/disk/by-uuid'
alias pw='bash -c '"'"'echo `tr -dc $([ $# -gt 1 ] && echo $2 || echo "A-Za-z0-9") < /dev/urandom | head -c $([ $# -gt 0 ] && echo $1 || echo 30)`'"'"' --'
alias mc='doas nvim /etc/portage/make.conf'
alias pm='doas nvim /etc/portage/package.mask'
alias pu='doas nvim /etc/portage/package.use'
alias pa='doas nvim /etc/portage/package.accept_keywords'
alias pr='doas nvim /etc/portage/repos.conf'
alias ew='doas emerge --sync; doas emerge -avuDN --keep-going --with-bdeps=y @world'
alias upp='doas emerge -DNputv @world'
alias 1s='doas emerge -upvDN1'
alias ed='doas emerge --depclean'
alias ep='doas emerge --prune'
alias ec='doas emerge --clean'
alias dc='doas eclean-dist -d'
alias er='doas emerge -cav'
alias en='doas emerge --noreplace'
alias es='doas emerge --sync'
alias esd='doas emerge --searchdesk'
alias ei='emerge --info'
alias es='emerge -s'
alias cc='ccache -s'
alias dt='doas cat /var/log/dmesg > file.txt'
alias e='doas env-update && source /etc/profile'
alias se='doas env-update && source /etc/profile'
alias ll='doas layman -L'
alias la='doas layman -a'
alias ld='doas layman -d'
 
