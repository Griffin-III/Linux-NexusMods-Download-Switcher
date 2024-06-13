#!/usr/bin/env bash

# Base Variables
SHAREDIR=~/.local/share
LOG=$SHAREDIR/wabbajack/Handler.log
JSON=$SHAREDIR/wabbajack/Switcher.json

# Log setup
if [ -f $LOG ]
then
	rm $LOG
fi


nxm_link=$1; shift

echo "Downloading: $nxm_link" >> $LOG

if [ -z "$nxm_link" ]; then
	echo "ERROR: please specify a NXM Link to download" >> $LOG
	exit 1
fi

nexus_game_id=${nxm_link#nxm://}
nexus_game_id=${nexus_game_id%%/*}


activegame=$(jq -r ".Active_$nexus_game_id" $JSON)
instanceappid=$(jq -r ".instances.[$activegame].appid" $JSON)
instancedir=$(jq -r ".instances.[$activegame].path" $JSON)

if [ $activegame -ge 0 ]
then
	echo "INFO: sending download to running Mod Organizer 2 instance" >> $LOG
	WINEESYNC=1 WINEFSYNC=1 protontricks-launch --appid "$instanceappid" "$instancedir/nxmhandler.exe" "$nxm_link"
	echo "$instanceappid" "$instancedir/nxmhandler.exe" "$nxm_link" >> $LOG
else
	echo "Could not download file because there is no Mod Organizer 2 instance for '$nexus_game_id'" >> $LOG
fi
