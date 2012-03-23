if isrunning; then
	. $forcesavefile
	if [ "$forcesave" == "on" ]; then
		case $1 in
			warn)
				sendtoscreen "broadcast Auto-Save in one minute. Expect brief lag."
			;;
			save)
				sendtoscreen "broadcast Auto-Save in ten seconds. Expect brief lag."
				sleep 10
				sendtoscreen "save-all"
				sendtoscreen "broadcast Auto-Save complete."
			;;
		*)
			echo "Usage: $0 [warn|save]"
		esac
	else
		echo "Force saving is disabled... Aborting..."
		exit
	fi
else
	echo "Server is not running... Aborting..."
	exit
fi