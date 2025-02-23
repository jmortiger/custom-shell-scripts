#!/usr/bin/env bats

function setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'

	bats_require_minimum_version 1.5.0

	# get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"
}

@test "Works for single item" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 array_remove --one -d $'\n' "hi" "${items[@]}"
	# assert_output $'ho\nhi\nho\noff\nto\nwork we go\n'
	assert_output "$(unset items[0];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
	run -0 array_remove --one -d $'\n' "off" "${items[@]}"
	assert_output $'hi\nho\nhi\nho\nto\nwork we go'
	run -0 array_remove --one -d $'\n' "work we go" "${items[@]}"
	assert_output $'hi\nho\nhi\nho\noff\nto'
}
@test "Works for single indexed item" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	# At the start
	run -0 array_remove --one -d $'\n' --at 0 "${items[@]}"
	assert_output "$(unset items[0];items=("${items[@]}");IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
	# In the middle
	run -0 array_remove --one -d $'\n' --at 4 "${items[@]}"
	assert_output "$(unset items[4];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
	# At the end
	run -0 array_remove --one -d $'\n' --at 6 "${items[@]}"
	assert_output "$(unset items[6];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
}
@test "Works for multiple items" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 array_remove --all -d $'\n' "hi" "${items[@]}"
	assert_output $'ho\nho\noff\nto\nwork we go'
	run -0 array_remove --all -d $'\n' "off" "${items[@]}"
	assert_output $'hi\nho\nhi\nho\nto\nwork we go'
	run -0 array_remove --all -d $'\n' "work we go" "${items[@]}"
	assert_output $'hi\nho\nhi\nho\noff\nto'
}
# @test "Works for multiple indexed items" {
# 	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
# 	# At the start
# 	run -0 array_remove --all -d $'\n' --at 0 "${items[@]}"
# 	assert_output "$(unset items[0];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
# 	# In the middle
# 	run -0 array_remove --all -d $'\n' --at 4 "${items[@]}"
# 	assert_output "$(unset items[4];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
# 	# At the end
# 	run -0 array_remove --all -d $'\n' --at 6 "${items[@]}"
# 	assert_output "$(unset items[6];IFS=$'\n';echo -nE "${items[*]}${IFS:0:1}")"
# }