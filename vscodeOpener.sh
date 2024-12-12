#!/usr/bin/env bash

# Opens VS Code w/ the recently opened files/folders/workspaces.

declare -a RECENT=($(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r ".entries[] | if .folderUri != null then .folderUri else .fileUri end"))
declare -a LABELS=($(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r '.entries[] | if .label != null then @uri "\(.label)" else false end'))
CHOICE=$(~/Desktop/userchoice.sh ${RECENT[@]} -l ${LABELS[@]} -f 0 -b "false" -d url -c Recent%20Workspaces:%20~~#~~ -p Enter%201-${#RECENT[@]},%20or%20anything%20else%20for%20an%20empty%20workspace.-\>%20)
if [ ${#CHOICE[@]} = 1 -a $CHOICE = 0 ]; then
    #echo " OPEN CODE IN EMPTY WOKSPACE"
    $(code --new-window)
else
    if [[ "${CHOICE[@]}" =~ ^vscode://.+$ ]]; then
    	# echo "code --new-window --open-url ${CHOICE[@]}"
    	$(code --new-window --open-url ${CHOICE[@]})
    elif [[ "${CHOICE[@]}" =~ ^(.*?):///?(.+)$ ]]; then
        # echo "${BASH_REMATCH[1]}"
        # echo "${BASH_REMATCH[2]}"
        # echo "code --new-window --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]} --log trace"
        $(code --new-window --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]} --log trace)
	else
		echo "${CHOICE[@]} isn't a proper uri."
		exit 255
	fi
fi
exit
