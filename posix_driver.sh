#!/bin/sh

oldstty=$(stty -g)
trap 'stty "$oldstty"' EXIT HUP INT TERM

stty -echo -icanon min 1 time 0

make_input() {
	while true
	do
		sleep 0.5
		echo s
	done &

	while true
	do
		C=$(dd if=/dev/tty bs=1 count=1 2>/dev/null)
		echo $C
	done 
}



make_input | sed -uE -e "$(./compile.sh)"
