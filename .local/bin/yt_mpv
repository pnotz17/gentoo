# displays a notif for 7s of the video being played
notify-send -t 7000 -i video-television \
"Playing" "`xclip -o -sel clip | xargs youtube-dl -e`"

# plays the link in mpv
mpv --fs `xclip -o -sel clip`
