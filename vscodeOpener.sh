#!/usr/bin/env bash

# Opens VS Code w/ the recently opened files/folders/workspaces.

readonly MY_PATH=$(realpath $0)
# echo "$MY_PATH"
MY_DIR=""
if [[ "$MY_PATH" =~ ^(.*)/[^/]+$ ]]; then
	readonly MY_DIR="${BASH_REMATCH[1]}"
else
	MY_DIR="Failed to get dir"
fi
# echo "$MY_DIR"
readonly TRUE="true"
readonly FALSE="false"
readonly BASE_COMMAND="code --new-window"
#readonly TRAILING_OPTIONS=" --log trace"
readonly TRAILING_OPTIONS=""
readonly HAS_HISTORY="[ -f $HOME/.config/Code/User/globalStorage/state.vscdb ]"
readonly HAS_NO_HISTORY="[ ! -f $HOME/.config/Code/User/globalStorage/state.vscdb ]"
readonly ERROR_NO_HISTORY=1
readonly ERROR_BAD_HISTORY=2
readonly ERROR_BAD_HISTORY_CHOICE=3
readonly ERROR_INVALID_URL=255

do_open() {
	# echo "$@"
	if [ $# = 1 -a $1 = 0 ]; then
	    #echo " OPEN CODE IN EMPTY WOKSPACE"
	    $($BASE_COMMAND$TRAILING_OPTIONS)
	else
	    if [[ "$@" =~ ^vscode://.+$ ]]; then
	    	# echo "$BASE_COMMAND --open-url $@"
	    	$($BASE_COMMAND --open-url $@$TRAILING_OPTIONS)
	    elif [[ "$@" =~ ^(.*?):///?(.+)$ ]]; then
	        # echo "${BASH_REMATCH[1]}"
	        # echo "${BASH_REMATCH[2]}"
	        # echo "$BASE_COMMAND --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
	        $($BASE_COMMAND --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}$TRAILING_OPTIONS)
		else
			echo "$@ isn't a proper uri."
			return $ERROR_INVALID_URL
		fi
	fi
	return $?
}

get_entries() {
	echo $(sqlite3 -readonly "$HOME/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r ".entries[]$@")
}

did_launch="$FALSE"
declare -a RECENT=()
while [ "$1" != "" ]; do
	if [[ "$1" =~ ^[0-9]+$ ]]; then
		echo "$1"
		did_launch="$TRUE"
		if $($HAS_NO_HISTORY); then exit $ERROR_NO_HISTORY; fi
		if [ ${#RECENT[@]} -le 0 ]; then
			RECENT=($(get_entries " | if .folderUri != null then .folderUri else .fileUri end"))
			if [ $? -ne 0 ]; then exit $ERROR_BAD_HISTORY; fi
		fi
		CHOICE=$1
		let CHOICE-=1
		echo "$CHOICE"
		if [ $CHOICE -lt ${#RECENT[@]} -a $CHOICE -ge 0 ]; then
			echo $(do_open ${RECENT[$CHOICE]})
		else
			exit $ERROR_BAD_HISTORY_CHOICE
		fi
		t_exit=$?
		if [ $t_exit -ne 0 ]; then
			exit $t_exit
		fi
	fi
	shift
done
if $($did_launch); then exit; fi
if $($HAS_NO_HISTORY); then
	read -p "Can't find Vs Code config (should be in '$HOME/.config/Code/User/globalStorage/state.vscdb').
Launch empty window? [y/n] " CHOICE
	if [ "$CHOICE" = "y" -o "$CHOICE" = "Y" ]; then $($BASE_COMMAND); fi
	exit $?
fi

readonly RECENT=($(get_entries " | if .folderUri != null then .folderUri else .fileUri end"))
readonly LABELS=($(get_entries ' | if .label != null then @uri "\(.label)" else false end'))

readonly CHOICE=$($MY_DIR/userchoice.sh ${RECENT[@]} -l ${LABELS[@]} -f 0 -b "false" -d url -c Recent%20Workspaces:%20~~#~~ -p Enter%201-${#RECENT[@]},%20or%20anything%20else%20for%20an%20empty%20workspace.-\>%20)
exit $(do_open "${CHOICE[@]}")
# if [ ${#CHOICE[@]} = 1 -a $CHOICE = 0 ]; then
#     #echo " OPEN CODE IN EMPTY WOKSPACE"
#     $($BASE_COMMAND)
# else
#     if [[ "${CHOICE[@]}" =~ ^vscode://.+$ ]]; then
#     	# echo "$BASE_COMMAND --open-url ${CHOICE[@]}"
#     	$($BASE_COMMAND --open-url ${CHOICE[@]})
#     elif [[ "${CHOICE[@]}" =~ ^(.*?):///?(.+)$ ]]; then
#         # echo "${BASH_REMATCH[1]}"
#         # echo "${BASH_REMATCH[2]}"
#         # echo "$BASE_COMMAND --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]} --log trace"
#         $($BASE_COMMAND --open-url vscode://${BASH_REMATCH[1]}/${BASH_REMATCH[2]} --log trace)
# 	else
# 		echo "${CHOICE[@]} isn't a proper uri."
# 		exit 255
# 	fi
# fi
# exit $?
