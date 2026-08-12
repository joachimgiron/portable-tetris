#!/bin/bash

make_input() {
	while true
	do
		sleep 0.5
		echo s
	done &

	while read -sr -N 1 C
	do
		echo $C
	done
}
make_input | sed -uE -f <(./compile.sh)
