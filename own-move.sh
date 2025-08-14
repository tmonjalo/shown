#! /bin/sh -e

# Shutter open/close/stop via OpenWebNet protocol

addr=192.168.3.33   # TO BE ADJUSTED
port=20000          # TO BE ADJUSTED

id=${1:-0}
move=${2:-0} # 0: off - 1: on/up - 2: down
delay_action=${3:-33}
delay_send=0.2

dir=/tmp/shown-move   # TO BE ADJUSTED
#dir=/var/lib/private/hass/shown-move # for Home Assistant
mkdir -p $dir
stamp=$dir/$id-$(date '+%H%M%S')

send () { # <command>
	echo "*99*9##$1" | nc -n $addr $port &
	sleep $delay_send
	kill $!
}

action () { # <id> <move>
	case $1 in
		L*)
			category=1 # lighting
			id=${1:1}
			delay_action=0
			;;
		A*)
			category=2 # automation
			id=${1:1}
			;;
		*)
			category=2 # automation, default
			id=$1
			;;
	esac
	move=$2
	printf 'category %d - id %d - move %d - result ' $category $id $move
	send "*$category*$move*$id##" |
	sed -n 's,.*\*#\*\(.\)##$,\1\n,p'
}

stop_if_last  () { # <file>
	rm -f $1
	id=$(echo $1 | sed -rn 's,.*/(.*)-.*,\1,p')
	test -n "$(ls $dir/$id-* 2>&-)" ||
	action $id $off
}

if [ "$move" != "$off" ] ; then
	touch $stamp

	# stop on exit if no more recent move
	signals="0 2 3 15"
	trap "stop_if_last $stamp ; trap - $signals" $signals
fi

# move
action $id $move

# stop old crashed commands
for f in $(find $dir -not -newermt '-2 minutes') ; do
	stop_if_last $f
done

if [ "$move" != 0 ] ; then
	# wait
	sleep $delay_action
fi
