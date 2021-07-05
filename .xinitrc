#!/bin/sh

# x settings
xrandr --output VGA1 --mode 1408x792_60.00 --scale-from 1920x1080 &
xset r rate 400 100

# dbus
if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
 eval `dbus-launch --sh-syntax`
 echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
fi

# scripts 
~/.local/bin/bars/dwm_bar &
~/.fehbg &

# autostart
dunst & 
xclickroot -r ~/.local/share/src/xmenu/xmenu.sh &

#dwm start loop
while true; do
    /usr/local/bin/dwm 2> /dev/null
done


