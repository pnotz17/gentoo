#
# ~/.bashrc
#

#exports
export TERM="st-256color"                     
export EDITOR="vim"  
export BROWSER="firefox-bin"          
export PATH=$HOME/.local/bin:$PATH
#export PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:'

#history
HISTCONTROL=ignoredups:erasedups  

#aliases
alias pw='bash -c '"'"'echo `tr -dc $([ $# -gt 1 ] && echo $2 || echo "A-Za-z0-9") < /dev/urandom | head -c $([ $# -gt 0 ] && echo $1 || echo 15)`'"'"' --'
alias ew='doas emerge -avuDN --quiet --alphabetical --keep-going -v --verbose-conflicts --with-bdeps=y @world'
alias dm='doas mount /dev/sda2 /hdd1 && doas mount /dev/sdb2 /hdd2 && doas mount /dev/sdc2 /hdd3'
alias sc='doas rm -r ~/.cache/ ~/.local/share/xorg/ ~/.local/share/recently-used.xbel'
alias ug='doas grub-mkconfig -o /boot/grub/grub.cfg'
alias pa='doas vim /etc/portage/package.accept_keywords'
alias cu='du -k --one-file-system -h --max-depth=1 /usr'
alias ds='doas emerge -aq --changed-deps --deep @world'
alias pun='doas vim /etc/portage/package.unmask'
alias e='doas env-update && source /etc/profile'
alias xr='xmonad --recompile; xmonad --restart'
alias pn='doas vim /etc/portage/package.unmask'
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
alias r='doas chown -R $USER:$USER'
alias pl='doas qlist -I > pkgs.txt'
alias pc='doas perl-cleaner --all'
alias lu='ls -l /dev/disk/by-uuid'
alias mf='fc-list | grep ".local"'
alias af='fc-list | grep "fonts"'
alias de='doas emerge --deselect'
alias ep='doas emerge --prune'
alias ec='doas emerge --clean'
alias sd='emerge --searchdesc'
alias poweroff='doas poweroff'
alias es='doas emerge --sync'
alias er='doas emerge -cavq'
alias dc='doas emerge -ac'
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
alias ex='tar -xpvf'
alias co='tar -cvJf'
alias u='git add -u'
alias s='git status'
alias gc='git clone'
alias l='doas ln -s'
alias vv='doas vim'
alias p='git push'
alias a='git add'
alias un='unzip'
alias d='doas'
alias v='vim'

#shopt
shopt -s autocd 
shopt -s cdspell 
shopt -s cmdhist 
shopt -s dotglob
shopt -s histappend 
shopt -s expand_aliases 
shopt -s checkwinsize 

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

#If not running interactively, don't do anything
[[ $- != *i* ]] && return

#syntax highlighting, autosuggestions, menu-completion, abbreviations with Bash Line Editor
source ~/.local/share/blesh/ble.sh     

#enable bash completion in interactive shells
  if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
      . /etc/bash_completion
  fi

function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}
PS1="\u@\e[31m\]\h:\w\[\033[0;36m\]\$(parse_git_branch_and_add_brackets) \[\033[0m\]\$ "
