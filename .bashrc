#
# ~/.bashrc
#

#exports
export TERM="st-256color"                     
export EDITOR="vim"  
export BROWSER="firefox-bin"          
export PATH=$HOME/.local/bin:$PATH
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:'

#history
HISTCONTROL=ignoredups:erasedups  

#aliases
alias pw='bash -c '"'"'echo `tr -dc $([ $# -gt 1 ] && echo $2 || echo "A-Za-z0-9") < /dev/urandom | head -c $([ $# -gt 0 ] && echo $1 || echo 15)`'"'"' --'
alias ew='doas emerge -avuDN --quiet --alphabetical --keep-going -v --verbose-conflicts --with-bdeps=y @world'
alias sc='doas rm -r ~/.cache/ ~/.local/share/xorg/ ~/.local/share/recently-used.xbel'
alias dm='doas mount /dev/sda2 /hdd1 && doas mount /dev/sdb2 /hdd2'
alias pa='doas vim /etc/portage/package.accept_keywords'
alias cu='du -k --one-file-system -h --max-depth=1 /usr'
alias ds='doas emerge -aq --changed-deps --deep @world'
alias ug='doas grub-mkconfig -o /boot/grub/grub.cfg'
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
alias cu='doas chown -R $USER:$USER'
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
alias ci='doas chattr -V +i'
alias cr='doas chattr -V -i'
alias rp='doas chmod -R 777'
alias dc='doas emerge -ac'
alias reboot='doas reboot'
alias et='doas etc-update'
alias 1='doas emerge -1vq'
alias en='doas emerge -nq'
alias um='doas umount -R'
alias ei='emerge --info'
alias x='doas chmod +x'
alias ss='doas spacefm'
alias gg='doas geany'
alias sl='doas ln -s'
alias ef='emerge -s'
alias ex='tar -xpvf'
alias co='tar -cvJf'
alias u='git add -u'
alias s='git status'
alias gc='git clone'
alias gp='git pull'
alias vv='doas vim'
alias a='git add *'
alias p='git push'
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

#ignore upper and lowercase with TAB
bind "set completion-ignore-case on"

#bash-line editor
source ~/.local/share/blesh/ble.sh

#git prompt
git_prompt() {
  BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/*\(.*\)/\1/')

  if [ ! -z $BRANCH ]; then
    echo -n "$(tput setaf 3)"

    if [ ! -z "$(git status --short)" ]; then
      echo " $(tput setaf 1)✗"
    fi
  fi
}

PS1="[\u@]\e[94m\]\h:\w\[\033[0;36m\]\$(git_prompt) \[\033[0m\]\$ "
#PS1="\[$(tput bold)\]\[$(tput setaf 1)\][\[$(tput setaf 3)\]\u\[$(tput setaf 2)\]@\[$(tput setaf 4)\]\h \[$(tput setaf 5)\]\W\[$(tput setaf 1)\]]\[$(tput setaf 7)\]\\$ \[$(tput sgr0)\]"
