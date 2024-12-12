#!/usr/bin/env bash

# #region Constants
readonly NAME="userchoice"
readonly ERROR_BAD_CHOICE=4
readonly DECODE_METHOD_ESCAPE="escape"
readonly DECODE_METHOD_URL="url"
readonly DECODE_METHOD_UNDERSCORE="underscore"
readonly TRUE="[ a = a ]"
readonly FALSE="[ a = b ]"
readonly DEFAULT_PROMPT="SELECT THE DESIRED OPTION> "
readonly DEFAULT_OPTION_COUNT_FORMAT_DECODED="VALUES: ~~#~~"
readonly DEFAULT_OPTION_COUNT_FORMAT_URL="VALUES:%20~~#~~"
readonly DEFAULT_OPTION_COUNT_FORMAT_ESCAPE="VALUES:\\x20~~#~~"
readonly DEFAULT_OPTION_COUNT_FORMAT_UNDERSCORE="VALUES:_~~#~~"
readonly DEFAULT_DECODE_METHOD=$DECODE_METHOD_ESCAPE
readonly DEFAULT_BLANK_LABEL=""
readonly DEFAULT_REPLACE_BLANK_LABEL_WITH=""
# #endregion Constants

# #region show_help
show_help() {
    cat << __EOF__
$NAME VAL1 VAL2... [-l | --label LABEL1 LABEL2...] [-p | --prompt PROMPT] [-z | --zero_based] [-d | --decode | --decode_method METHOD]

Presents a list of choices to the user and returns their response.

Parameters:
    list of values
    -l: a list of labels to display to users. If empty, the raw values will be displayed instead. If some values don't have a corresponding label, -b | --blank_label can be used to identify them, and --replace_blank_label_with can be used to override display behavior.
	-p | --prompt PROMPT: Sets the prompt to use. Defaults to "$DEFAULT_PROMPT".
    -z | --zero_based: Sets the choice indicies to be zero based.
    -d | --decode | --decode_method METHOD: The decoding method to use for values and labels.
		* "$DECODE_METHOD_URL" to use url decoding
		* "$DECODE_METHOD_ESCAPE" to use escape decoding (i.e. use "\\\\" to encode escape sequences)
		* "$DECODE_METHOD_UNDERSCORE" to use underscore decoding (i.e. replaces all underscores with spaces)
		* Anything else will result in no decoding being used. If this is used, ensure there are no spaces in your values nor labels.
		Defaults to "$DEFAULT_DECODE_METHOD"
    -b | --blank_label VALUE: The value to use to indicate a label should be skipped. Defaults to "$DEFAULT_BLANK_LABEL".
    --replace_blank_label_with VALUE: The value to replace empty labels with. If unset, will use the corresponding entry in the values list.
    -r | --decode_value_before_return: The return value will be decoded before returning.
    -f | --return_on_fail[ure] VALUE: The value to be returned on failure. If unset, will return the user's input value.
    -t | --passthrough: directly return the user's entered input; do not attempt to resolve to the corresponding value.
	-c | --option_count_format FORMAT: The format to show the # of results in. The substring "~~#~~", if present, will be replaced with the number of results. Will be decoded according to "--decode_method". Set to an empty string to disable (e.g. $NAME -c "" option1 option2). Defaults to "$DEFAULT_OPTION_COUNT_FORMAT_DECODED".
    -h | --help: Display this help text.
Error Level of $ERROR_BAD_CHOICE if user input invalid.
__EOF__
#    -e | --error_on_fail: Set the error level on failure.
}
# #endregion show_help

decode_method=$DEFAULT_DECODE_METHOD
decode_value_before_return=$FALSE
zero_based=$FALSE
passthrough=$FALSE
return_on_failure=$TRUE
prompt=$DEFAULT_PROMPT
blank_label=$DEFAULT_BLANK_LABEL
replace_blank_label_with=$DEFAULT_REPLACE_BLANK_LABEL_WITH
option_count_format=$DEFAULT_OPTION_COUNT_FORMAT_DECODED
LABELS=()
VALUES=()
not_zero_based() {
    if $($zero_based); then
        echo $FALSE
    else
        echo $TRUE
    fi
}

# TODO: TEST
replace_count() {
    # echo -e "$(echo $option_count_format | sed -E "s/~~#~~/${#VALUES[@]}/g")"
    echo "$option_count_format" | sed -E "s/~~#~~/${#VALUES[@]}/g"
}

url_decode() {
    echo -e $(echo "$1" | sed -E "s/\\+/ /g" | sed -E "s/%([0-9a-fA-F][0-9a-fA-F])/\\\x\1/g")
}

escape_decode() {
    echo -e $(echo "$1" | sed -E "s/\\\\/\\\/g")
}

# TODO: TEST
underscore_decode() {
    echo -e $(echo "$1" | sed -E "s/_/ /g")
}

decode() {
    if [[ "$decode_method" = $DECODE_METHOD_URL ]]; then
        echo $(url_decode $1)
    elif [[ "$decode_method" = $DECODE_METHOD_UNDERSCORE ]]; then
        echo $(underscore_decode $1)
    elif [[ "$decode_method" = $DECODE_METHOD_ESCAPE ]]; then
        echo $(escape_decode $1)
    else
        echo $1
    fi
}

#########################region GET OPTIONS#########################
useLabels=$FALSE
useValues=$TRUE
while [ "$1" != "" ]; do
    #If it's an option
    if [[ $1 =~ ^\- ]]; then
        useLabels=$FALSE
        if [[ ${#VALUES[@]} -gt 0 ]]; then
            useValues=$FALSE
        fi
    fi
    case $1 in
        # #region Flags
		-l | --labels )
		    useLabels=$TRUE
		    ;;
		-t | --passthrough )
		    passthrough=$TRUE
		    ;;
		-z | --zero_based )
		    zero_based=$TRUE
		    ;;
		-r | --return_decoded )
		    decode_value_before_return=$TRUE
		    ;;
		# #endregion Flags
        # #region Values
		-d | --decode | --decode_method )
		    shift
		    decode_method=$1
		    ;;
		-p | --prompt )
		    shift
		    prompt=$1
		    ;;
		-c | --option_count_format )
		    shift
		    option_count_format=$1
		    ;;
		-b | --blank_label )
		    shift
		    blank_label=$1
		    ;;
		--replace_blank_label_with )
		    shift
		    replace_blank_label_with=$1
		    ;;
		-f | --return_on_fail | --return_on_failure )
		    shift;
		    return_on_failure=$1
		    ;;
		# #endregion Values
        -h | --help )
            show_help
            exit
            ;;
        * )
            if $($useLabels); then
                LABELS[${#LABELS[@]}]=$1
            elif $($useValues); then
                VALUES[${#VALUES[@]}]=$1
            else
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done
if [[ !( "$prompt" = "" ) && !( "$prompt" = "$DEFAULT_PROMPT" ) ]]; then
	prompt="$(decode $prompt)"
fi
#########################endregion GET OPTIONS#########################
if [[ ${#VALUES[@]} = 0 ]]; then
    show_help
    exit 1
fi

#########################region PREP PROMPT#########################
# stty cread 
# readonly LABELS
# readonly VALUES
prompt_prefix=""
count=0
valid_options=()
valid_labels=()
for label in ${VALUES[@]}; do
    # readonly -a VALUES[$count]
    if [ "$prompt_prefix" != "" ]; then
        prompt_prefix="$prompt_prefix
"
    fi
    if [[ (( ${#LABELS[@]} > 0 )) && (( ${#LABELS[@]} > $count )) && $blank_label != ${LABELS[count]} ]]; then
        label=${LABELS[count]}
    elif [[ (( ${#LABELS[@]} > 0 )) && (( ${#LABELS[@]} > $count )) && $blank_label == ${LABELS[count]} && $replace_blank_label_with != "" ]]; then
        label=$replace_blank_label_with
    fi
    if $($(not_zero_based)); then
        let count+=1
    fi
    valid_options[${#valid_options[@]}]=$count
    valid_labels[${#valid_labels[@]}]=$(decode $label)
    prompt_prefix="$prompt_prefix$count: $(decode $label)"
    if $($(not_zero_based)); then
        let count-=1
    fi
    let count+=1
done
# readonly count prompt
if [[ !( "$option_count_format" = "" ) ]]; then
	if [[ !( "$option_count_format" = "$DEFAULT_OPTION_COUNT_FORMAT_DECODED" ) ]]; then
		prompt_prefix="$(decode $(replace_count))
$prompt_prefix"
	else
		prompt_prefix="$(replace_count)
$prompt_prefix"
	fi
fi
read -p "$prompt_prefix
$prompt" CHOICE
# readonly CHOICE
#########################endregion PREP PROMPT#########################

#################################################
# Parse Results
#################################################
if $($passthrough); then
	echo $CHOICE
	exit
fi
count=0
for o in ${valid_options[@]}; do
    if [ "$CHOICE" = "$o" ]; then
        SELECTION=${VALUES[count]}
        if $($decode_value_before_return); then
            SELECTION=$(decode $SELECTION)
        fi
        #read -p "Value selected is $SELECTION" whatever
        echo $SELECTION
        exit
    fi
    let count+=1
done
count=0
for o in ${valid_labels[@]}; do
    if [ "$CHOICE" = "$o" ]; then
        SELECTION=${VALUES[count]}
        if $($decode_value_before_return); then
            SELECTION=$(decode $SELECTION)
        fi
        #read -p "Value selected is $SELECTION" whatever
        echo $SELECTION
        exit
    fi
    let count+=1
done
if [ "$return_on_failure" = "$TRUE" ]; then
    echo $CHOICE
else
    echo $return_on_failure
fi
exit $ERROR_BAD_CHOICE
