#!/usr/bin/env bash

fetchmail --check 2>/dev/null | while read line; do
    new=$(echo "$line" | sed 's/(//' | awk '{print $1-$3}')
    if [ "$new" != 0 ] && [ ! -e ~/.dwm.msg ]; then
        echo "New mail($new)" > ~/.dwm.msg
        echo "!!! !!! !!!" >> ~/.dwm.msg
        sleep 5
        if grep '^New mail' ~/.dwm.msg >/dev/null 2>/dev/null; then
            rm -f ~/.dwm.msg
        fi
    fi
done
