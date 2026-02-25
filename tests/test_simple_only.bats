#!/usr/bin/env bats

@test "simple installer test" {
    source installer.sh
    [[ -n "${VERSION:-}" ]]
}

@test "simple logger test" {
    source src/logger.sh
    declare -f log_info
}

@test "simple colors test" {
    source src/colors.sh
    [[ -n "${COLOR_RED:-}" ]]
}
