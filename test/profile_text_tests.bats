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

@test "Can count a single line correctly in display mode" {
	declare -ri COLS=10
	declare -r value="123456789"
	run -0 profile_text --output-columns "$COLS" --display_mode --rows "$value"
	assert_output 1
	run -0 profile_text --output-columns "$COLS" --display_mode --chars-at _ "$value"
	assert_output $((${#value}))
	run -0 profile_text --output-columns "$COLS" --display_mode --row-at _ "$value"
	assert_output "$value"
	run -0 profile_text --output-columns "$COLS" --display_mode --col-at _ "$value"
	assert_output $((${#value}))
}
@test "Can count a single line correctly in edit mode" {
	declare -ri COLS=10
	declare -r value="123456789"
	run -0 profile_text --output-columns "$COLS" --edit_mode --rows "$value"
	assert_output 1
	run -0 profile_text --output-columns "$COLS" --edit_mode --chars-at _ "$value"
	assert_output 9
	run -0 profile_text --output-columns "$COLS" --edit_mode --col-at _ "$value"
	assert_output 10
	run -0 profile_text --output-columns "$COLS" --edit_mode --row-at _ "$value"
	assert_output "$value"
}
@test "Can correctly handle the difference between display and edit mode" {
	declare -ri COLS=10
	declare -r value="1234567890"
	run -0 profile_text --output-columns "$COLS" --display_mode --rows "$value"
	assert_output 1
	run -0 profile_text --output-columns "$COLS" --edit_mode --rows "$value"
	assert_output 2
	run -0 profile_text --output-columns "$COLS" --display_mode --row-at _ "$value"
	assert_output "$value"
	run -0 profile_text --output-columns "$COLS" --edit_mode --row-at _ "$value"
	assert_output ''
	run -0 profile_text --output-columns "$COLS" --display_mode --chars-at _ "$value"
	assert_output 10
	run -0 profile_text --output-columns "$COLS" --edit_mode --chars-at _ "$value"
	assert_output 0
	run -0 profile_text --output-columns "$COLS" --display_mode --col-at _ "$value"
	assert_output 10
	run -0 profile_text --output-columns "$COLS" --edit_mode --col-at _ "$value"
	assert_output 1
}

@test "Can count multiple lines w/o control characters correctly in display mode" {
	declare -ri COLS=10
	declare -r value="1234567890_234567890"
	run -0 profile_text --output-columns "$COLS" --display_mode --rows "$value"
	assert_output 2
	run -0 profile_text --output-columns "$COLS" --display_mode --chars-at _ "$value"
	assert_output 10
	run -0 profile_text --output-columns "$COLS" --display_mode --col-at _ "$value"
	assert_output 10
	run -0 profile_text --output-columns "$COLS" --display_mode --row-at _ "$value"
	assert_output "_234567890"
}
@test "Can count multiple lines w/o control characters correctly in edit mode" {
	declare -ri COLS=10
	declare value="1234567890_2345"
	run -0 profile_text --output-columns "$COLS" --edit_mode --rows "$value"
	assert_output 2
	run -0 profile_text --output-columns "$COLS" --edit_mode --chars-at _ "$value"
	assert_output 5
	run -0 profile_text --output-columns "$COLS" --edit_mode --col-at _ "$value"
	assert_output 6
	run -0 profile_text --output-columns "$COLS" --edit_mode --row-at _ "$value"
	assert_output '_2345'
	declare -r value+="67890"
	run -0 profile_text --output-columns "$COLS" --edit_mode --rows "$value"
	assert_output 3
	run -0 profile_text --output-columns "$COLS" --edit_mode --chars-at _ "$value"
	assert_output 0
	run -0 profile_text --output-columns "$COLS" --edit_mode --col-at _ "$value"
	assert_output 1
	run -0 profile_text --output-columns "$COLS" --edit_mode --row-at _ "$value"
	assert_output ''
}