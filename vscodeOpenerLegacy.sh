#!/bin/bash

# Opens VS Code w/ the recently opened files/folders/workspaces.
# This parses the uri to open the resource directly. Does not work for non-"file://" uri sequences (e.g. dev containers)

urldecode() {
    echo -e $(echo $1 | sed -E "s/\\+/ /g" | sed -E "s/%([0-9a-fA-F][0-9a-fA-F])/\\\x\1/g")
}
stty cread 
RECENT=($(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r ".entries[] | if .folderUri != null then .folderUri else .fileUri end"))
# readonly RECENT
prompt="..."
count=0
for file in ${RECENT[@]}; do
    file=$(urldecode "$file")
    RECENT[count]=$file
    # readonly -a RECENT[$count]
    let count+=1
    if [ "$prompt" != "..." ]; then
        prompt="$prompt
"
    else
        prompt=""
    fi
    prompt="$prompt$count: $file"
done
# readonly count prompt
echo "RECENT: $count
0: New Window
$prompt"
read -p "SELECT THE DESIRED OPTION> " CHOICE
shopt -s extglob
if [[ $CHOICE == !([0123456789]) ]] || [ $CHOICE -le 0 ] || [ $CHOICE -gt $count ]; then
    echo "New Window"
    $(code)
else
    if [[ "${RECENT[$CHOICE-1]}" =~ ^file://(.+)$ ]]; then
        #echo "${BASH_REMATCH[1]}"
        $(code ${BASH_REMATCH[1]})
    else
        $(${RECENT[$CHOICE-1]})
    fi
    #$(code ${RECENT[$CHOICE-1]})
fi
shopt -u extglob
exit
