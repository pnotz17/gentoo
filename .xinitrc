#!/bin/sh

# X settings
xrandr --output VGA1 --mode 1408x792_60.00 --scale-from 1920x1080 &
xset r rate 400 100

# Autostart
~/.local/bin/bars/gentoo_bar &
~/.local/bin/xsession_destroyah &
~/.fehbg &
xclickroot -r ~/git/xmenu/xmenu.sh &
dunst &

#dwm start loop
while true; do
    /usr/local/bin/dwm 2> /dev/null
done


