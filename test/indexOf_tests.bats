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

@test "Works with different flag order" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 indexOf --value 'ho' --first "${items[@]}"
	assert_output 1
}
# bats file_tags=single
# bats test_tags=forward
@test "Finds matching index" {
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
# bats test_tags=forward
@test "Finds first matching index" {
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
# bats test_tags=backward
@test "Finds last matching index" {
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
# bats file_tags=multiple
# bats test_tags=forward
@test "Finds all matching indices" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --all "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf --all "hi" "${items[@]}"
	assert_output '0 2'
	run -0 indexOf --all "ho" "${items[@]}"
	assert_output '1 3'
	run -0 indexOf --all "off" "${items[@]}"
	assert_output 4
	run -0 indexOf --all "work we go" "${items[@]}"
	assert_output 6
	run indexOf "work" "${items[@]}"
	assert_output -1
}
# bats test_tags=forward
@test "Finds all matching indices forwards" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --first --all "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf --first --all "hi" "${items[@]}"
	assert_output '0 2'
	run -0 indexOf --first --all "ho" "${items[@]}"
	assert_output '1 3'
	run -0 indexOf --first --all "off" "${items[@]}"
	assert_output 4
	run -0 indexOf --first --all "work we go" "${items[@]}"
	assert_output 6
	run indexOf "work" "${items[@]}"
	assert_output -1
}
# bats test_tags=backward
@test "Finds all matching indices backwards" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --last --all "hello" "${items[@]}"
	assert_output -1
	run -0 indexOf --last --all "hi" "${items[@]}"
	assert_output '2 0'
	run -0 indexOf --last --all "ho" "${items[@]}"
	assert_output '3 1'
	run -0 indexOf --last --all "off" "${items[@]}"
	assert_output 4
	run -0 indexOf --last --all "work we go" "${items[@]}"
	assert_output 6
	run indexOf "work" "${items[@]}"
	assert_output -1
}
# bats file_tags=single,regex
# bats test_tags=forward
@test "Finds matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex "h[^o]" "${items[@]}"
	assert_output 0
	run -0 indexOf --regex "^[^t]o$" "${items[@]}"
	assert_output 1
	run -0 indexOf --regex "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex "work$" "${items[@]}"
	assert_output -1
}
# bats test_tags=forward
@test "Finds first matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex --first "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex --first "h[^o]" "${items[@]}"
	assert_output 0
	run -0 indexOf --regex --first "^[^t]o$" "${items[@]}"
	assert_output 1
	run -0 indexOf --regex --first "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex --first "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex --first "work$" "${items[@]}"
	assert_output -1
}
# bats test_tags=backward
@test "Finds last matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex --last "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex --last "h[^o]" "${items[@]}"
	assert_output 2
	run -0 indexOf --regex --last "^[^t]o$" "${items[@]}"
	assert_output 3
	run -0 indexOf --regex --last "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex --last "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex --last "work$" "${items[@]}"
	assert_output -1
}
# bats file_tags=multiple,regex
# bats test_tags=forward
@test "Finds all matching indices w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex --all "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex --all "h[^o]" "${items[@]}"
	assert_output '0 2'
	run -0 indexOf --regex --all "^[^t]o$" "${items[@]}"
	assert_output '1 3'
	run -0 indexOf --regex --all "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex --all "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex --all "work$" "${items[@]}"
	assert_output -1
}
# bats test_tags=forward
@test "Finds all matching indices forwards w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex --first --all "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex --first --all "h[^o]" "${items[@]}"
	assert_output '0 2'
	run -0 indexOf --regex --first --all "^[^t]o$" "${items[@]}"
	assert_output '1 3'
	run -0 indexOf --regex --first --all "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex --first --all "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex --first --all "work$" "${items[@]}"
	assert_output -1
}
# bats test_tags=backward
@test "Finds all matching indices backwards w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -1 indexOf --regex --last --all "^l" "${items[@]}"
	assert_output -1
	run -0 indexOf --regex --last --all "h[^o]" "${items[@]}"
	assert_output '2 0'
	run -0 indexOf --regex --last --all "^[^t]o$" "${items[@]}"
	assert_output '3 1'
	run -0 indexOf --regex --last --all "f$" "${items[@]}"
	assert_output 4
	run -0 indexOf --regex --last --all "[[:blank:]]" "${items[@]}"
	assert_output 6
	run indexOf --regex --last --all "work$" "${items[@]}"
	assert_output -1
}
# bats file_tags=single,inverted
# bats test_tags=forward
@test "Finds non-matching index" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 indexOf --invert "hello" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert "hi" "${items[@]}"
	assert_output 1
	run -0 indexOf --invert "ho" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert "off" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert "work we go" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert "work" "${items[@]}"
	assert_output 0
}
# bats test_tags=forward
@test "Finds first non-matching index" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 indexOf --invert --first "hello" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert --first "hi" "${items[@]}"
	assert_output 1
	run -0 indexOf --invert --first "ho" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert --first "off" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert --first "work we go" "${items[@]}"
	assert_output 0
	run -0 indexOf --invert --first "work" "${items[@]}"
	assert_output 0
}
# bats test_tags=backward
@test "Finds last non-matching index" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	run -0 indexOf --invert --last "hello" "${items[@]}"
	assert_output 6
	run -0 indexOf --invert --last "hi" "${items[@]}"
	assert_output 6
	run -0 indexOf --invert --last "ho" "${items[@]}"
	assert_output 6
	run -0 indexOf --invert --last "off" "${items[@]}"
	assert_output 6
	run -0 indexOf --invert --last "work we go" "${items[@]}"
	assert_output 5
	run -0 indexOf --invert --last "work" "${items[@]}"
	assert_output 6
}
# bats file_tags=multiple,inverted
# bats test_tags=forward
@test "Finds all non-matching indices" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --all'
	run -0 $func "hello" "${items[@]}"
	assert_output '0 1 2 3 4 5 6'
	run -0 $func "hi" "${items[@]}"
	assert_output '1 3 4 5 6'
	run -0 $func "ho" "${items[@]}"
	assert_output '0 2 4 5 6'
	run -0 $func "off" "${items[@]}"
	assert_output '0 1 2 3 5 6'
	run -0 $func "work we go" "${items[@]}"
	assert_output '0 1 2 3 4 5'
	run -0 $func "work" "${items[@]}"
	assert_output '0 1 2 3 4 5 6'
}
# bats test_tags=forward
@test "Finds all non-matching indices forwards" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --first --all'
	run -0 $func "hello" "${items[@]}"
	assert_output '0 1 2 3 4 5 6'
	run -0 $func "hi" "${items[@]}"
	assert_output '1 3 4 5 6'
	run -0 $func "ho" "${items[@]}"
	assert_output '0 2 4 5 6'
	run -0 $func "off" "${items[@]}"
	assert_output '0 1 2 3 5 6'
	run -0 $func "work we go" "${items[@]}"
	assert_output '0 1 2 3 4 5'
	run -0 $func "work" "${items[@]}"
	assert_output '0 1 2 3 4 5 6'
}
# bats test_tags=backward
@test "Finds all non-matching indices backwards" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --last --all'
	run -0 $func "hello" "${items[@]}"
	assert_output '6 5 4 3 2 1 0'
	run -0 $func "hi" "${items[@]}"
	assert_output '6 5 4 3 1'
	run -0 $func "ho" "${items[@]}"
	assert_output '6 5 4 2 0'
	run -0 $func "off" "${items[@]}"
	assert_output '6 5 3 2 1 0'
	run -0 $func "work we go" "${items[@]}"
	assert_output '5 4 3 2 1 0'
	run $func "work" "${items[@]}"
	assert_output '6 5 4 3 2 1 0'
}
# bats file_tags=single,regex,inverted
# bats test_tags=forward
@test "Finds non-matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output 1
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output 0
	run -0 $func "f$" "${items[@]}"
	assert_output 0
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output 0
}
# bats test_tags=forward
@test "Finds first non-matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex --first'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output 1
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output 0
	run -0 $func "f$" "${items[@]}"
	assert_output 0
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output 0
}
# bats test_tags=backward
@test "Finds last non-matching index w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex --last'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output 6
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output 6
	run -0 $func "f$" "${items[@]}"
	assert_output 6
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output 5
}
# bats file_tags=multiple,regex,inverted
# bats test_tags=forward
@test "Finds all non-matching indices w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex --all'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output '1 3 4 5 6'
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output '0 2 4 5 6'
	run -0 $func "f$" "${items[@]}"
	assert_output '0 1 2 3 5 6'
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output '0 1 2 3 4 5'
}
# bats test_tags=forward
@test "Finds all non-matching indices forwards w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex --first --all'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output '1 3 4 5 6'
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output '0 2 4 5 6'
	run -0 $func "f$" "${items[@]}"
	assert_output '0 1 2 3 5 6'
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output '0 1 2 3 4 5'
}
# bats test_tags=backward
@test "Finds all non-matching indices backwards w/ regex" {
	declare -a items=('hi' 'ho' 'hi' 'ho' 'off' 'to' 'work we go')
	declare -r func='indexOf --invert --regex --last --all'
	run -1 $func "^h|o" "${items[@]}"
	assert_output -1
	run -0 $func "h[^o]" "${items[@]}"
	assert_output '6 5 4 3 1'
	run -0 $func "^[^t]o$" "${items[@]}"
	assert_output '6 5 4 2 0'
	run -0 $func "f$" "${items[@]}"
	assert_output '6 5 3 2 1 0'
	run -0 $func "[[:blank:]]" "${items[@]}"
	assert_output '5 4 3 2 1 0'
}