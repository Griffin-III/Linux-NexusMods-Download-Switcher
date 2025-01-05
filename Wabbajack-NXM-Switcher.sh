#!/usr/bin/env bash

# Base Variables
SHAREDIR=~/.local/share
LOG=$SHAREDIR/wabbajack/Switcher.log
JSON=$SHAREDIR/wabbajack/Switcher.json
JSONTMP=$SHAREDIR/wabbajack/.tmpjq

# Log setup
if [ -f $LOG ]
then
	rm $LOG
fi

# custom colors for certain messages
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color


# install code
function install () {
	echo "Installing Nexus Handler"
	echo "Creating Wabbajack folder"
	mkdir $SHAREDIR/wabbajack
	echo "Setting Up Nexus Handler"
	cp wabbajack-nxm-handler.sh $SHAREDIR/wabbajack
	# swap ~ for actual home path of user in .desktop files for compatibility
	sed -i "s|~|$HOME|g" "wabbajack-nxm-handler.desktop"
	cp wabbajack-nxm-handler.desktop $SHAREDIR/applications
	echo "Setting Up Switcher Shortcut"
	cp Wabbajack-NXM-Switcher.sh $SHAREDIR/wabbajack
	sed -i "s|~|$HOME|g" "Wabbajack-NXM-Switcher.desktop"
	cp Wabbajack-NXM-Switcher.desktop $SHAREDIR/applications

	echo "Creating JSON file"
	if ! [ -f $JSON ]
	then
		jq -n "{\"instances\":[]}" > $JSON
	fi

	# Temporarily remove other types that could interfere with our browser
	if [ -f $SHAREDIR/applications/modorganizer2-nxm-handler.desktop ]
	then
		echo "Removing other mime types"
		mv $SHAREDIR/applications/modorganizer2-nxm-handler.desktop $SHAREDIR/wabbajack
	fi
	if [ -f $SHAREDIR/applications/ModOrganizer-steamtinkerlaunch-dl.desktop ]
	then
		echo "Removing other mime types"
		mv $SHAREDIR/applications/ModOrganizer-steamtinkerlaunch-dl.desktop $SHAREDIR/wabbajack
	fi

	echo "Updating Mime Database"
	xdg-mime default $SHAREDIR/applications/wabbajack-nxm-handler.desktop x-scheme-handler/nxm
	update-desktop-database ~/.local/share/applications
	echo -e "\n${CYAN}Installation complete. You can move this script anywhere or launch it from your application launcher as 'Wabbajack NXM Switcher'.${NC}"
	read -s -p "Press enter to continue..."
}

#uninstall code
function uninstall () {
	echo "Uninstalling Nexus Handler"
	default=0
	#if [ -f $SHAREDIR/applications/wabbajack-nxm-handler.desktop ]
	#then
		echo "Removing Nexus Handler"
		rm $SHAREDIR/wabbajack/wabbajack-nxm-handler.sh
		rm $SHAREDIR/applications/wabbajack-nxm-handler.desktop
		echo "Removing Switcher Shortcut"
		rm $SHAREDIR/wabbajack/Wabbajack-NXM-Switcher.sh
		rm $SHAREDIR/applications/Wabbajack-NXM-Switcher.desktop
	#fi

	# Restore removed handlers
	if [ -f $SHAREDIR/wabbajack/modorganizer2-nxm-handler.desktop ]
	then
		default=1
		echo "Restoring other mime types"
		mv $SHAREDIR/wabbajack/modorganizer2-nxm-handler.desktop $SHAREDIR/applications
	fi
	if [ -f $SHAREDIR/wabbajack/ModOrganizer-steamtinkerlaunch-dl.desktop ]
	then
		default=2
		echo "Restoring other mime types"
		mv $SHAREDIR/wabbajack/ModOrganizer-steamtinkerlaunch-dl.desktop $SHAREDIR/applications
	fi

	echo "Updating Mime Database"
	if [ $default -eq 1 ]
	then
		xdg-mime default $SHAREDIR/applications/modorganizer2-nxm-handler.desktop x-scheme-handler/nxm
	elif [ $default -eq 2 ]
	then
		xdg-mime default $SHAREDIR/applications/ModOrganizer-steamtinkerlaunch-dl.desktop x-scheme-handler/nxm
	fi

	update-desktop-database ~/.local/share/applications

	echo -e "${RED}Remove Switcher Configs?${NC}"
	read -p "Y/N: " yninput
		yninput="${yninput,,}"

	case "$yninput" in
			y | yes)
				echo -e "${RED}Removing Files...${NC}"
				gio trash $SHAREDIR/wabbajack
				;;
			* | n | no)
				echo "Exiting"
				;;
	esac
}

# change instance code
function switch () {
	echo ""
	# get length of instances array
	instances=$(jq '.instances | length' $JSON)
	# subtract one for the loop
	instances=$(( instances - 1 ))
	# loop through instances to display to user
	for i in $(seq 0 $instances)
	do
		game=$(jq -r ".instances.[$i].game" $JSON)
		isactive=$(jq -r ".Active_$game" $JSON)
		if [ $isactive -eq $i ] 2>/dev/null
		then
			echo -e "${CYAN}$i${NC}: $(jq ".instances.[$i].name" $JSON) ${CYAN}[Active | $game]${NC}"
		else
			echo -e "${CYAN}$i${NC}: $(jq ".instances.[$i].name" $JSON)"
		fi

	done
	echo ""
	echo -e "${RED}Select active instance${NC}"
	read -p 'Number: ' num

	#sanity check. without this can erase entire json
	if [ $num -le $instances ] && [ $num -ge 0 ]
	then
		active true $num
	else
		echo -e "${RED}Bad input. Exiting...${NC}"
	fi
	start
}


# add code
function add () {
	echo -e "${CYAN}Enter the name of the instance (Can be anything)${NC}"
	read -p 'Name: ' name
	echo -e "${CYAN}Enter the game exactly as it appears in its Nexus url${NC}. E.g: nexusmods.com/${RED}skyrimspecialedition${NC}/mods/1"
	read -p 'Game: ' game
	echo -e "${CYAN}Enter the Steam AppID you're using to launch MO2${NC}. Launch protontricks --gui and it's the number next to the game's name"
	read -p 'AppID: ' appid
	echo -e "${CYAN}Enter the path to this instance's MO2 folder WITHOUT trailing slash /${NC}"
	read -p 'Path: ' path
	jqappend $name $game $appid $path
	start
}

# remove code
function remove () {
	echo ""
	# get length of instances array
	instances=$(jq '.instances | length' $JSON)
	# subtract one for the loop
	instances=$(( instances - 1 ))
	# loop through instances to display to user
	for i in $(seq 0 $instances)
	do
		echo -e "${CYAN}$i${NC}: $(jq ".instances.[$i].name" $JSON)"
	done
	echo ""
	echo -e "${RED}Select which instance to remove${NC}"
	read -p 'Number: ' num

	#sanity check. without this can erase entire json
	if [ $num -le $instances ] && [ $num -ge 0 ]
	then
		jqremove $num
	else
		echo -e "${RED}Bad input. Exiting...${NC}"
	fi
	start
}

function jqappend () {
	# vars = name, game, appid, path
	jq ".instances[.instances | length] = {\"name\":\"$1\",\"game\":\"$2\",\"appid\":\"$3\",\"path\":\"$4\"}" $JSON > $JSONTMP
	mv $JSONTMP $JSON
}

function jqremove () {
	# var 1 = stored instance to remove
	active false $1
	jq "del(.instances.[$1])" $JSON > $JSONTMP
	mv $JSONTMP $JSON
}

function active () {
	# vars = bool, instance
	# $1 is true then add active
		# for game $2 if $2 exists update else add with value $3
	# $1 is false remove active
		# for game $2 if $3 choose another instance
		# if no other instances remove active
	game=$(jq -r ".instances.[$2].game" $JSON)
	if $1
	then
		#add
		jq ". += {\"Active_$game\":\"$2\"}" $JSON > $JSONTMP
		mv $JSONTMP $JSON
	else
		#remove
		jq "del(.Active_$game)" $JSON > $JSONTMP
		mv $JSONTMP $JSON
	fi
}
function start () {
	echo ""
	# prompt user for options
	echo -e "'${CYAN}S)witch${NC}' - Change active profile"
	echo -e  "'${CYAN}A)dd${NC}' - Add a new modlist instance"
	echo -e  "'${CYAN}R)emove${NC}' - Remove an existing instance"
	echo -e  "'${CYAN}I)nstall${NC}' - Setup Nexus URL Handler"
	echo -e  "'${CYAN}U)ninstall${NC}' - Remove Nexus URL Handler"
	echo -e "Or press Enter to ${RED}Quit${NC}\n"
	read -p 'Input choice: ' promptinput

	promptinput="${promptinput,,}"

	case "$promptinput" in
		i | install)
			install
			;;
		u | uninstall)
			uninstall
			;;
		s | switch)
			switch
			;;
		a | add)
			add
			;;
		r | remove)
			remove
			;;
		*)
			echo "Exiting"
			;;
	esac
}

start
