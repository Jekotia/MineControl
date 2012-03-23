#!/bin/bash

serverbackup() {
	cd $serverworldbackupdir
	echo "Backing up entire '$server_Dir' directory to tar archive..."
	tar -zcf full_$dateformat_$timeformat.tar.gz $server_Dir/
	echo "Dumping copies of all MySQL data to SQL file..."
	mysqldump -u $mysqluser -p$mysqlpass --all-databases > $mysqlworldbackupdir/full_$dateformat_$timeformat.sql
}

worldbackup() {
  for ((i=0;i<$numworlds;i++)); do
	if [ "$1" == "${worlds[$i]}" ]; then
	  echo "Removing previous backup from '$backuptmp${worlds[$i]}/'"
	  rm -rf ${backuptmp}${worlds[$i]}/
	  if isrunning; then
		sendtoscreen "say Starting backup for world '${worlds[$i]}'"
		sendtoscreen "save-off"
	  fi
	  echo "Creating temp directory '${backuptmp}${worlds[$i]}'..."
	  mkdir -p ${backuptmp}${worlds[$i]}/
	  echo "Copying '${server_Dir}${worlds[$i]}' to '${backuptmp}${worlds[$i]}'..."
	  cp -pR ${server_Dir}${worlds[$i]} ${backuptmp}
	  echo "Changing to backup dir"
	  cd ${backuptmp}
	  echo "Creating zip archive file of '${backuptmp}${worlds[$i]}/' in '${worldbackupdir}${worlds[$i]}/..."
	  zip -v ${worldbackupdir}${worlds[$i]}/${dateformat}_${timeformat}.zip -r ${worlds[$i]}
	  if isrunning; then
		sendtoscreen "save-on"
		sendtoscreen "say Backup of world '${worlds[$i]}' completed."
	  fi
	else
	  echo "'$1' did not match any worlds in the configuration! Backup sequence aborted."
	fi
  done
}

worldlogbackup() {
  for ((i=0;i<$numworlds;i++)); do
	if [ "$1" == "${worlds[$i]}" ]; then
	  WORLD="${worlds[$i]}"
	  if isrunning; then
		echo sendtoscreen "say Starting Logblock database backup for world '$WORLD'"
	  fi
	  STR="lb-${worlds[$i]} lb-${worlds[$i]}-chest lb-${worlds[$i]}-kills lb-${worlds[$i]}-sign"
	  mysqldump -u $mysqluser -p$mysqlpass logblock $STR > ~/backups/mysql/${worlds[$i]}_$dateformat"_"$timeformat.sql
	  if isrunning; then
		echo sendtoscreen "say Logblock database Backup of world '$WORLD' completed."
	  fi
	fi
  done
}

mysqlbackup() {
	cd ~/
	zip -v backups/`date "+%Y-%m-%d-%H-%M-%S"`.zip -r $server_Dir
	mysqldump -u $mysqluser -p$mysqlpass --all-databases > ~/backups/mysql/full_$dateformat"_"$timeformat.sql
}
