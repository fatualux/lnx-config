#!/usr/bin/env bats

@test "simple test" {
    [[ true ]]
}

@test "file exists test" {
    [[ -f "installer.sh" ]]
}

@test "command success test" {
    run echo "hello"
    [[ $status -eq 0 ]]
    [[ "$output" == "hello" ]]
}
