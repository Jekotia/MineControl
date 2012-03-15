#!/bin/bash
. /home/mc/scripts/init.sh

case $1 in
    warn)
        sendtoscreen "broadcast Starting a world backup in one minute. Expect lag for a little bit."
        ;;
    full)
        serverbackup
        ;;
    world)
        safeworldbackup $2
        ;;
    mysql)
        mysqlbackup
        ;;
    *)
        echo "Usage: $0 [warn|full|world|mysql]"
esac