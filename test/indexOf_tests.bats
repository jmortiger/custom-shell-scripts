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

@test "Works" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf "hi" "${items[@]}"
	assert_output 0
	run -0 indexOf "ho" "${items[@]}"
	assert_output 1
	run -0 indexOf "off" "${items[@]}"
	assert_output 4
	run -0 indexOf "work we go" "${items[@]}"
	assert_output 6
	run indexOf "work" "${items[@]}"
	assert_output -1
}
@test "Works with different flag order" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 indexOf --value 'ho' --first "${items[@]}"
	assert_output 1
}
@test "Works Forward" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --first "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf --first "hi" "${items[@]}"
	assert_output 0
	run -0 indexOf --first "ho" "${items[@]}"
	assert_output 1
	run -0 indexOf --first "off" "${items[@]}"
	assert_output 4
	run -0 indexOf --first "work we go" "${items[@]}"
	assert_output 6
	run indexOf --first "work" "${items[@]}"
	assert_output -1
}
@test "Works Backwards" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	# ! indexOf --last "hello" "${items[@]}"
	run -1 indexOf --last "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf --last "hi" "${items[@]}"
	assert_output 2
	run -0 indexOf --last "ho" "${items[@]}"
	assert_output 3
	run -0 indexOf --last "off" "${items[@]}"
	assert_output 4
	run -0 indexOf --last "work we go" "${items[@]}"
	assert_output 6
	run indexOf --last "work" "${items[@]}"
	assert_output -1
}
# @test "Works for multiple items" {
# 	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
# 	declare -a testItems=('hello' 'dolly')
# 	! indexOf "${testItems[@]@A}" "${items[@]}"
# 	declare -a testItems=('hello' 'hi')
# 	echo "${testItems[@]@A}"
# 	echo "${items[@]@Q}"
# 	run indexOf "${testItems[*]@A}" "${items[@]}"
# 	echo "$output"
# 	run -0 indexOf "${testItems[*]@A}" "${items[@]}"
# 	declare -a testItems=('work we' 'go')
# 	! indexOf "${testItems[@]@A}" "${items[@]}"
# }