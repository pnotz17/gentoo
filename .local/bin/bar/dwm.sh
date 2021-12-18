#!/bin/sh

while true; do

MAIL=`curl -su USER:PASS https://mail.google.com/mail/feed/atom || echo "<fullcount>unknown number of</fullcount>"`;MAIL=`echo "$MAIL" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
IP=$(for i in `ip r`; do echo $i; done | grep -A 1 src | tail -n1)
UPTIME=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
PACKAGES=$(checkupdates 2> /dev/null |pacman -Q  |  wc -l)
PACMAN=$(checkupdates 2> /dev/null | wc -l )
FILESYSTEM=$(df -Ph | grep "/dev/sda" | awk {'print $5'})
RAM=$(free -h --kilo | awk '/^Mem:/ {print $3 "/" $2}')
MEM=$(free | awk '/^Mem/ { printf("%.2f%\n", $3/$2 * 100.0) }')
LINUX=$(uname -r)
NETDOWN=$(R1=`cat /sys/class/net/enp2s0/statistics/rx_bytes`;sleep 1;R2=`cat /sys/class/net/enp2s0/statistics/rx_bytes`;RBPS=`expr $R2 - $R1`;RKBPS=`expr $RBPS / 1024`;printf  "($RKBPS kb)")
NETUP=$(T1=`cat /sys/class/net/enp2s0/statistics/tx_bytes`;sleep 1;T2=`cat /sys/class/net/enp2s0/statistics/tx_bytes`;TBPS=`expr $T2 - $T1`;TKBPS=`expr $TBPS / 1024`;printf  "($TKBPS kb)")
CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
FORECAST=$(curl wttr.in/YOURCITY?format="%l:+%m+%p+%w+%t+%c+%C")
WEATHER=$(curl 'https://wttr.in/YOURCITY,YOURCOUNTRY?format=%t')
VOL=$(amixer get Master | awk '$0~/%/{print $4}' | tr -d '[]')
TEMP=$(sensors|awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}')"C"
DATEALT=$(date '+%Y-%m-%d %H:%M:%S')
DATE=$(date "+%b %d, %R")
BAT=$(acpi -b | awk '{ print $4 " " }' | tr -d ',' | tr -d ' ')

xsetroot -name "$UPTIME :: Fs $FILESYSTEM :: Tmp $TEMP :: Cpu $CPU :: Mem $MEM :: Vol $VOL :: Tx/Up $NETUP :: Tx/Down $NETDOWN :: Fc $WEATHER :: $DATE ::"
#xsetroot -name "^c#FFFFFF^$UPTIME ^c#FFFFFF^| ^c#FFFFFF^Ip: ^c#FF0000^$IP ^c#FFFFFF^| ^c#FFFFFF^Mail: ^c#FF0000^$MAIL ^c#FFFFFF^| ^c#FFFFFF^Temp: ^c#FF0000^$TEMP ^c#FFFFFF^| ^c#FFFFFF^Cpu: ^c#FF0000^$CPU ^c#FFFFFF^| ^c#FFFFFF^Mem: ^c#FF0000^$MEM ^c#FFFFFF^| ^c#FFFFFF^Tx/up: ^c#FF0000^$UP ^c#FFFFFF^| ^c#FFFFFF^Tx/do: ^c#FF0000^$DOWN ^c#FFFFFF^| ^c#FFFFFF^Vol: ^c#FF0000^$VOL ^c#FFFFFF^| ^c#FFFFFF^$DATE ^c#FFFFFF^|"
	sleep 3s
done &
