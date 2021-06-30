#!/bin/bash

## DISK
hdd() {
  hdd="$(df -h | awk 'NR==4{print $3, $5}')"
  echo -e "Hdd: $hdd"
}

## TEMP
temp() {
	cputemp=`sensors|awk 'BEGIN{i=0;t=0;b=0}/id [0-9]/{b=$4};/Core/{++i;t+=$3}END{if(i>0){printf("%0.1f\n",t/i)}else{sub(/[^0-9.]/,"",b);print b}}'`"C"
	echo "Core: $cputemp"
}

## CPU
cpu() {
  read cpu a b c previdle rest < /proc/stat
  prevtotal=$((a+b+c+previdle))
  sleep 0.5
  read cpu a b c idle rest < /proc/stat
  total=$((a+b+c+idle))
  cpu=$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))
  echo -e "Cpu: $cpu%"
}

## RAM
mem() {
	mem=$(free | awk '/^Mem/ { printf("%.2f%\n", $3/$2 * 100.0) }')
	echo "Ram $mem"
}

## VOLUME
vol() {
		audio=$(
		amixer sget Master |
		sed '5!d;
		s_]..*__g;
		s_.*\[__'
	)
	muted=$(
		amixer sget Master |
		sed '5!d' |
		cut -f8 -d' '
	)

	if [ $muted = '[on]' ]; then
		echo "Vol: $audio"
	else
		echo "Muted $audio"
	fi
}

## UPDATES
updates() {
updates="$(~/.local/bin/modules/sb_updates)"
echo -e "Pacman: $updates"
}
	
while :; do
    echo "$(updates)  | $(hdd)  |  $(temp)  |  $(cpu)  |  $(mem)  |  $(vol)  |"
	sleep 3
done

