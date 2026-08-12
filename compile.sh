#!/bin/sh

W=10
H=20
A=$((W*H))
RNG='<[01]+\|[01]*>'
HEAD='[^,]*,'
SCORE='[a-d]*'

generate_spawns() {
<spec sed -E -e 's/.$/\0#/g' -e 's/^$/|/g' | tr -d '\n' | tr '|' '\n' | sed -E 's/#$//g' | while true
do
	for i in $(seq 0 3)
	do
		read S$i || break 2
	done


		eval SHAPE=$S0

		MATRIX_W=$(echo -n $SHAPE | cut -d '#' -f1 | tr -d '\n' | wc -c)
		FOLDED=$(echo ",$SHAPE,$NEXT" | sed -E -e ':b' -e 's/^(.*),(.)(.*),(.)(.*)$/\1\2\4,\3,\5/g' -e 't b' -e's/,//g')
		MATCH_MATRIX="$(echo $SHAPE | tr '[:upper:]' ' ')"
		REPLACE_MATRIX=$SHAPE
		MATCH_CORE=$(echo "$MATCH_MATRIX" | sed -E -e "s/#/.{$((W - MATRIX_W))}/g" -e 's/[[:upper:] ]+/)\0(/g')
		REPLACE_CORE=$(echo "$REPLACE_MATRIX" | sed -E -e 's/^|[.#]+/\\\\\\\\$((BR+=1))/g')
		BR=1
		eval EXPANDED_REPLACE_CORE=\""$REPLACE_CORE"\"
		C=$(echo $SHAPE | tr -cd '[:upper:]' | head -c1)
		NEXT=$(echo $C | tr 'abcdefg' 'bcdefga')
		printf "s/($SCORE;$RNG)$C;[0-9],(.{$(((W - MATRIX_W) / 2))}$MATCH_CORE)/\\\\1,$EXPANDED_REPLACE_CORE/\n"

done

}

generate_rotations() {
<spec sed -E -e 's/.$/\0#/g' -e 's/^$/|/g' | tr -d '\n' | tr '|' '\n' | sed -E 's/#$//g' | while true
do
	for i in $(seq 0 3)
	do
		read S$i || break 2
	done


	for i in $(seq 0 3)
	do
		eval SHAPE=\$S$i
		eval NEXT=\$S$(((i + 1) % 4))

		MATRIX_W=$(echo -n $SHAPE | cut -d '#' -f1 | tr -d '\n' | wc -c)
		FOLDED=$(echo ",$SHAPE,$NEXT" | sed -E -e ':b' -e 's/^(.*),(.)(.*),(.)(.*)$/\1\2\4,\3,\5/g' -e 't b' -e's/,//g')
		MATCH_MATRIX="$(echo $FOLDED | fold -w2 | sed -E -e 's/\.\././g' -e 's/([[:upper:]])[[:upper:].]/\1/g' -e 's/\.[[:upper:]]/ /g' -e 's/##/#/g' | tr -d '\n')"
		REPLACE_MATRIX="$(echo $FOLDED | fold -w2 | sed -E -e 's/\.\././g' -e 's/[[:upper:]]\./ /g' -e 's/[[:upper:].]([[:upper:]])/\1/g' -e 's/##/#/g' | tr -d '\n')"
		MATCH_CORE=$(echo "$MATCH_MATRIX" | sed -E -e "s/#/.{$((W - MATRIX_W))}/g" -e 's/[[:upper:] ]+/)\0(/g')
		REPLACE_CORE=$(echo "$REPLACE_MATRIX" | sed -E -e 's/(^\.*)|(\.+$)|\.*#\.*/\\\\\\\\$((BR+=1))/g')
		BR=1
		eval EXPANDED_REPLACE_CORE=\""$REPLACE_CORE"\"
		printf "s/($SCORE;$RNG);$i,(.{$W}*.{,$((W-MATRIX_W))}$MATCH_CORE)/\\\\1;$(((i + 1) % 4)),$EXPANDED_REPLACE_CORE/\n"
		echo "t end_rotate"
	done

done

}

cat <<EOF

x
/^$/ {
	s/^$/;<$(cat /dev/random | tr -cd '01' | head -c 64)|>;0,$(yes . | head -n $A | tr -d '\n' | tr . ' ')/
	x
	b spawn
}
x
/s/ b down
/a/ b left
/d/ b right
/w/ b rotate
g
d


:spawn
x
:spawn_rng
$(cat xorshift64plus.sed)
s/<([01]+)\|([01]*)([01]{3})>/<\1|\2\3>[\3]/g
/\[000\]/ {
	s/\[000\]//g
	b spawn_rng
}
s/\[001\]/A/g
s/\[010\]/B/g
s/\[011\]/C/g
s/\[100\]/D/g
s/\[101\]/E/g
s/\[110\]/F/g
s/\[111\]/G/g
s/\|[01]+>/|>/g
s///g
t spawn_lbl1
:spawn_lbl1
$(generate_spawns)
s/^($SCORE;$RNG),([^0-9][^,])/\1;0,\2/g
x
t e
s/.*/GAME OVER/
q 1

:down
g
s/^($HEAD)(.*)$/\1\2\2/g
:l1
s/($HEAD.*)(.{$A})[[:upper:]]/\1\2 /g
t l1
:l2
s/^($HEAD[^[:upper:]]*)([[:upper:]])(.{$((A+W-1))}) /\1 \3\2/g
t l2

/$HEAD.*[[:upper:]].{$A}/ {
	g
	y/ABCDEFGH/abcdefgh/
:down_l3
	s/^($HEAD#*)(.{$W}*)[[:lower:]]{$W}/\1#$(yes ' ' | head -n $W | tr -d '\n')\2/g
t down_l3
	s/^($SCORE);($RNG;[0-3]),####/\1cbb;\2,/
	s/^($SCORE);($RNG;[0-3]),###/\1bbb;\2,/
	s/^($SCORE);($RNG;[0-3]),##/\1b;\2,/
	s/^($SCORE);($RNG;[0-3]),#/\1aaaa;\2,/
:down_l4
s/^([b-e]*)(a+)(b+)/\1\3\2/g
s/^([c-e]*)([a-b]+)(c+)/\1\3\2/g
s/^([d-e]*)([a-c]+)(d+)/\1\3\2/g
s/^([a-d]+)(e+)/\2\1/g
s/^([b-e]*)a{10}/\1b/g
s/^([c-e]*)b{10}/\1c/g
s/^([d-e]*)c{10}/\1d/g
s/^(e*)d{10}/\1e/g
t down_l4
	h
	b spawn
}
s/^($HEAD).{$A}(.*)$/\1\2/g
h
b e

:left
g
s/^($HEAD)(.*)$/\1\2\2/g
:left_l1
s/($HEAD.*)(.{$A})[[:upper:]]/\1\2 /g
t left_l1
:left_l2
s/^($HEAD[^[:upper:]]{$W}*[^[:upper:]]{1,$((W-1))})([[:upper:]])(.{$((A-2))}) /\1 \3\2/g
t left_l2

/$HEAD.*[[:upper:]].{$A}/ b e

s/^($HEAD).{$A}(.*)$/\1\2/g
h
b e

:right
g
s/^($HEAD)(.*)$/\1\2\2/g
:right_l1
s/($HEAD.*)(.{$A})[[:upper:]]/\1\2 /g
t right_l1
:right_l2
s/^($HEAD[^[:upper:]]{$W}*[^[:upper:]]{0,$((W-2))})([[:upper:]])(.{$((A))}) /\1 \3\2/g
t right_l2

/$HEAD.*[[:upper:]].{$A}/ b e

s/^($HEAD).{$A}(.*)$/\1\2/g
h
b e

:rotate
g
$(generate_rotations)
:end_rotate
h
b e


:e

g
s/^($SCORE);$RNG;[0-3],/\1,/g
s/^(e*)(d*)(c*)(b*)(a*),/,\1,\2,\3,\4,\5,/
:e_l1
s/,[^,0-9]{0},/,0,/g
s/,[^,0-9]{1},/,1,/g
s/,[^,0-9]{2},/,2,/g
s/,[^,0-9]{3},/,3,/g
s/,[^,0-9]{4},/,4,/g
s/,[^,0-9]{5},/,5,/g
s/,[^,0-9]{6},/,6,/g
s/,[^,0-9]{7},/,7,/g
s/,[^,0-9]{8},/,8,/g
s/,[^,0-9]{9},/,9,/g
t e_l1
s/[,;]//g
s/([^0-9]{$W})([^0-9]{$W})/<,\1,\2>/g
:e_l2
s/<([^,>]*),([^,>])([^,>]*),([^,>])([^,>]*)>/<\1[\2\4],\3,\5>/g
t e_l2
s/,//g

s/A|a/5/g 
s/B|b/4/g 
s/C|c/3/g 
s/D|d/2/g 
s/E|e/1/g 
s/F|f/4/g 
s/G|g/3/g 
s/ /0/g

s/\[(.)(.)\]/[4\1;3\2m▄/g

s/<([^>]*)>/▐\1[0m▌\n/g
s/^([0-9]+)/[2J\rSCORE:\10\n▗$(yes ▄ | head -n $W | tr -d '\n')▖\n/
s/$/▝$(yes ▀ | head -n $W | tr -d '\n')▘/
:e_l3
s/:( *)0([0-9])/:\1 \2/g
t e_l3
p
d
EOF
