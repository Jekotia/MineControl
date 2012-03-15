#! /bin/bash
. /home/mc/scripts/init.sh

case $1 in
    all)
        if isrunning; then
            if [ "$twitteralerts" == "true" ]; then
                echo "hascrashed=false" > $twitteralertsfile
            fi
            echo $dateformat"_"$timeformat "- Stop command logged as part of nightly restarts." >> $statuslog
            sendtoscreen "save-all"
            sendtoscreen "kick * Nightly backups begin now. Server will be down for a few minutes before coming back up."
            sendtoscreen "stop"
        fi
        loopcounter=0
        while isrunning; do
            sleep 20
            ((loopcounter=$loopcounter+1))
            echo "On loop $loopcounter."
        done
        for ((v=0;v<$numworlds;v++)); do
           worldbackup ${worlds[$v]}
           worldlogbackup ${worlds[$v]}
        done
        logroll
        screen -dmS overviewer bash ~/scripts/utilities.sh ovr update
        screen -dmS schematic-list bash ~/scripts/schematic-list.sh
        MC start
        ;;
    warn)
        sendtoscreen "broadcast Nightly backups begin in $2 minute(s). Server will be down for a few minutes before coming back up."
        echo "forcesave=off" > $forcesavefile
        ;;
    *)
        echo "Usage: $0 [warn|all]"
esac