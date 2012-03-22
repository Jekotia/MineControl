#! /bin/bash
. ${HOME}/Dropbox/GitHub/MineControl/src/05-init.sh

case $1 in
	wgb)
		if [ "$2" == "edit" ]; then
			nano $wgblacklist
			exit
		fi
		if [ "$2" == "reload" ]; then
			for ((i=0;i<$numworlds;i++)); do
				echo "Replacing $serverdir'plugins/WorldGuard/worlds/'${worlds[$i]}'/blacklist.txt with $wgblacklist'"
				cp $wgblacklist $serverdir'plugins/WorldGuard/worlds/'${worlds[$i]}'/blacklist.txt'
				echo ----------------------------------
			done
			if isrunning; then
				sendtoscreen "wg reload"
				echo "WorldGuard reload command sent to server."
				echo ----------------------------------
				resumebukkit
			fi
			exit
		fi
		echo "Usage: MCutil wgb <edit|update>"
		;;
	pex)
		if [ "$2" == "edit" ]; then
			nano $serverdir/plugins/PermissionsEx/permissions.yml
			exit
		fi
		if [ "$2" == "reload" ]; then
			if isrunning; then
				sendtoscreen "pex reload"
				echo "PermissionsEx reload command sent to server."
				resumebukkit
			fi
			exit
		fi
		echo "Usage: MCutil pex <edit|reload>"
		;;
	ovr)
		if [ "$2" == "update" ]; then
			if isrunning; then
				sendtoscreen "save-off"
			fi
			for ((i=0;i<$numworlds;i++)); do
				rm -rf ${tempdir}ovr-${worlds[$i]}
				mkdir -p ${tempdir}ovr-${worlds[$i]}
				cp -pR ${serverdir}${worlds[$i]}/* ${tempdir}/ovr-${worlds[$i]}
			done
			if isrunning; then
				sendtoscreen "save-on"
			fi
			screen -dmS overviewer overviewer --config="/home/mc/overviewer.conf"
		fi
		;;
	cmd)
		if [ "$2" == "edit" ]; then
			nano ${serverdir}plugins/CommandHelper/config.txt
			exit
		fi
		if [ "$2" == "reload" ]; then
			if isrunning; then
				sendtoscreen "reloadaliases"
				echo "CommandHelper reload command sent to server."
				resumebukkit
			fi
			exit
		fi
		echo "Usage: MCutil cmd <edit|reload>"
		;;

	*)
		echo "Usage: MCutil wgb <edit|reload>"
		echo "Usage: MCutil pex <edit|reload>"
		echo "Usage: MCutil ovr <update>"
		echo "Usage: MCutil cmd <edit|reload>"
esac