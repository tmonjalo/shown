#! /bin/sh -e

# Shutter open/close/stop via OpenWebNet protocol

addr=192.168.3.33   # TO BE ADJUSTED
port=20000          # TO BE ADJUSTED
category=2          # TO BE ADJUSTED

off=0
up=1
down=2

id=${1:-0}
move=${2:-$down}
delay_action=${3:-33}
delay_send=0.2

dir=/tmp/shown-move   # TO BE ADJUSTED
mkdir -p $dir
stamp=$dir/$id-$(date '+%H%M%S')

send () { # <command>
	echo "*99*9##$1" | nc $addr $port &
	sleep $delay_send
	kill $!
}

action () { # <category> <id> <direction>
	printf 'category %d - id %d - direction %d - result ' $1 $2 $3
	send "*$1*$3*$2##" |
	sed -n 's,.*\*#\*\(.\)##$,\1\n,p'
}

stop_if_last  () { # <category> <file>
	rm -f $2
	id=$(echo $2 | sed -rn 's,.*/(.*)-.*,\1,p')
	test -n "$(ls $dir/$id-* 2>&-)" ||
	action $1 $id $off
}

if [ "$move" != "$off" ] ; then
	touch $stamp

	# stop on exit if no more recent move
	signals="0 2 3 15"
	trap "stop_if_last $category $stamp ; trap - $signals" $signals
fi

# move
action $category $id $move

# stop old crashed commands
for f in $(find $dir -not -newermt '-2 minutes') ; do
	stop_if_last $category $f
done

if [ "$move" != "$off" ] ; then
	# wait
	sleep $delay_action
fi
