#!/bin/bash

# Tests for readline configuration

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

print_section "Readline Config Tests"

CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/config"
READLINE_FILE="$CONFIG_DIR/readline.sh"

assert_file_exists "readline.sh exists" "$READLINE_FILE"
assert_success "readline.sh syntax OK" "bash -n \"$READLINE_FILE\""
assert_success "show-all-if-ambiguous configured" "grep -q \"show-all-if-ambiguous\" \"$READLINE_FILE\""

print_summary
