sendtoscreen() {
	screen -q -S $server_Screen -X stuff "`printf "\r"`" #clears the consoles input area prior to sending the intended command
	screen -q -S $server_Screen -X stuff "$1$(echo -ne '\r')" > /dev/null
}

isrunning() {
	ps ax | grep -v grep | grep -v screen | grep "$server_File" > /dev/null
	return $?
}

server_Resume() {
	screen -x $server_Screen
}

logroll() {
	if isrunning; then
		echo "Stop the Minecraft server before rolling logs!"
	else
		cd $server_Dir
		for ((i=0;i<$numlogroll;i++)); do
			mv ${logroll[$i]}.log ${logdir}/${logroll[$i]}/${dateformat}.log
		done
	fi
}