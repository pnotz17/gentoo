# variables
export TERM=st-256color
export EDITOR=nvim
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

# autocompletion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# fzf
if [[ ! "$PATH" == *~/.zsh/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/$HOME/.zsh/.fzf/bin"
fi

# ls - colors
export CLICOLOR=1
ls --color=auto &> /dev/null 

# plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source ~/.zsh/.fzf/shell/completion.zsh 2> /dev/null
source ~/.zsh/.fzf/shell/key-bindings.zsh 2> /dev/null

# aliases
alias pw='bash -c '"'"'echo `tr -dc $([ $# -gt 1 ] && echo $2 || echo "A-Za-z0-9") < /dev/urandom | head -c $([ $# -gt 0 ] && echo $1 || echo 30)`'"'"' --'
alias ew='doas emerge -avuDN --keep-going --with-bdeps=y @world'
alias pa='doas nnvim /etc/portage/package.accept_keywords'
alias cu='du -k --one-file-system -h --max-depth=1 /usr'
alias ds='doas emerge -p --changed-deps --deep @world '
alias e='doas env-update && source /etc/profile'
alias ap='doas ls /var/db/pkg/* > pkglist.txt'
alias pm='doas nvim /etc/portage/package.mask'
alias c='git commit -m "changes in dotfiles"'
alias pu='doas nvim /etc/portage/package.use'
alias pe='doas nvim /etc/portage/package.env'
alias pr='doas nvim /etc/portage/repos.conf'
alias sf='doas emerge --resume --skipfirst'
alias rb='doas rm -rf /var/cache/binpkgs/*'
alias mk='doas nvim /etc/portage/make.conf'
alias lv='doas qlist -IRv > pkgversion.txt'
alias rt='doas rm /var/cache/distfiles/*'
alias l='doas qlist -I > pkgs.txt'
alias build='doas make clean install'
alias w='cat /var/lib/portage/world'
alias pc='doas perl-cleaner --all'
alias lu='ls -l /dev/disk/by-uuid'
alias en='doas emerge --noreplace'
alias mf='fc-list | grep ".local"'
alias af='fc-list | grep "fonts"'
alias sc='doas rm -rf ~/.cache/*'
alias dc='doas emerge --depclean'
alias de='doas emerge --deselect'
alias ep='doas emerge --prune'
alias ec='doas emerge --clean'
alias sd='emerge --searchdesc'
alias poweroff='doas poweroff'
alias es='doas emerge --sync'
alias r='doas chmod -R 777'
alias er='doas emerge -cav'
alias reboot='doas reboot'
alias eu='doas etc-update'
alias ls='ls --color=auto'
alias 1='doas emerge -1'
alias ll='doas layman -L'
alias la='doas layman -a'
alias ld='doas layman -d'
alias ei='emerge --info'
alias x='doas chmod +x'
alias ss='doas spacefm'
alias dg='doas geany'
alias t='doas touch'
alias ef='emerge -s'
alias cc='ccache -s'
alias v='doas nnvim'
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

# Prompt
setopt prompt_subst
PROMPT='%F{none}%n@%F{#FF00FF}%m:%15<..<%~%<<$(git_branch_test_color)%F{none}%# '
neofetch
