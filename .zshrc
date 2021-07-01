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
alias ew='doas emerge -avuDN --quiet --alphabetical --keep-going -v --verbose-conflicts --with-bdeps=y @world'
alias pa='doas vim /etc/portage/package.accept_keywords'
alias cu='du -k --one-file-system -h --max-depth=1 /usr'
alias ds='doas emerge -a --changed-deps --deep @world'
alias e='doas env-update && source /etc/profile'
alias ap='doas ls /var/db/pkg/* > pkglist.txt'
alias pm='doas vim /etc/portage/package.mask'
alias c='git commit -m "changes in dotfiles"'
alias pu='doas vim /etc/portage/package.use'
alias pe='doas vim /etc/portage/package.env'
alias pr='doas vim /etc/portage/repos.conf'
alias sf='doas emerge --resume --skipfirst'
alias rb='doas rm -rf /var/cache/binpkgs/*'
alias lv='doas qlist -IRv > pkgversion.txt'
alias mk='doas vim /etc/portage/make.conf'
alias rt='doas rm /var/cache/distfiles/*'
alias build='doas make clean install'
alias w='cat /var/lib/portage/world'
alias pl='doas qlist -I > pkgs.txt'
alias pc='doas perl-cleaner --all'
alias lu='ls -l /dev/disk/by-uuid'
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
alias et='doas etc-update'
alias ls='ls --color=auto'
alias 1='doas emerge -1vq'
alias en='doas emerge -nq'
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
alias d='doas'

# git prompt
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr 'M' 
zstyle ':vcs_info:*' unstagedstr 'M' 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats \ '%F{5}[%F{2}%b%F{5}] %F{2}%c%F{3}%u%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' enable git 
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
  [[ $(git ls-files --other --directory --exclude-standard | sed q | wc -l | tr -d ' ') == 1 ]] ; then
  hook_com[unstaged]+='%F{1}??%f'
fi
}

precmd () { vcs_info }
PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_} %f%# '

