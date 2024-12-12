#!/bin/bash

urldecode() {
    echo -e $(echo $1 | sed -E "s/\\+/ /g" | sed -E "s/%([0-9a-fA-F][0-9a-fA-F])/\\\x\1/g")
}

RECENT=($(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r ".entries[] | if .folderUri != null then .folderUri else .fileUri end"))
declare -a LABELS=$(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq ".entries[].label | if .label != null then .label else false end")
#LABELS=($(sqlite3 -readonly "/home/jmor/.config/Code/User/globalStorage/state.vscdb" "SELECT [value] FROM ItemTable WHERE [key] = 'history.recentlyOpenedPathsList'" | jq -r ".entries[] | if .label != null then .label elif .folderUri != null then .folderUri else .fileUri end"))
# readonly RECENT
echo ${LABELS[@]}
echo ${#LABELS[@]}
echo ${RECENT[@]}
echo ${#RECENT[@]}
prompt=""
count=0
#for file in ${RECENT[@]}; do
    #file=$(urldecode "$file")
    #RECENT[count]=$file
    # readonly -a RECENT[$count]
    #if [ "$prompt" != "" ]; then
    #    prompt="$prompt
#"
    #fi
    #if [ "${LABELS[count]}" != "false" ]; then
    #    prompt="$prompt$(($count+1)): ${LABELS[count]} ($file)"
    #else
    #    prompt="$prompt$(($count+1)): $file"
    #fi
    #let count+=1
#done
#echo $count
#count=0
#echo $count
for label in ${LABELS[@]}; do
    file=$(urldecode "${RECENT[count]}")
    RECENT[count]=$file
    let count+=1
    # readonly -a RECENT[$count]
    if [ "$prompt" != "" ]; then
        prompt="$prompt
"
    fi
    if [ "$label" != "false" ]; then
        prompt="$prompt$count): ${label} ($file)"
    else
        prompt="$prompt$count): $file"
    fi
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
    $(code ${RECENT[$CHOICE-1]})
fi
shopt -u extglob
exit
