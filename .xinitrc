#!/bin/sh

# x 
xrandr --output VGA1 --mode 1408x792_60.00 --scale-from 1920x1080 &
xset r rate 400 100

# dbus
if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
 eval `dbus-launch --sh-syntax`
 echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

# autostart
/usr/local/bin/xclickroot -r ~/git/xmenu/xmenu.sh &
/usr/bin/feh --bg-fill ~/wallpaper.jpg &
/usr/bin/dunst ~/.config/dunst/dunstrc &
#~/.local/bin/bars/emojibar.sh &

# dwm start loop
#while true; do
    #/usr/local/bin/dwm 2> /dev/null
#done
exec $HOME/.local/bin/xmonad
