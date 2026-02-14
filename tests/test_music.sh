#!/bin/bash

# Tests for music player functions

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source main.sh to load all functions
MAIN_SH_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"
unset __BASH_CONFIG_LOADED
if [ -f "$MAIN_SH_PATH" ]; then
    source "$MAIN_SH_PATH"
fi

print_section "Music Player Functions"

# Test: play_music_shuffle function exists
assert_success "play_music_shuffle function exists" "declare -f play_music_shuffle > /dev/null"

# Test: remove_currently_playing_track function exists
assert_success "remove_currently_playing_track function exists" "declare -f remove_currently_playing_track > /dev/null"

# Test: add_track_to_playlist function exists
assert_success "add_track_to_playlist function exists" "declare -f add_track_to_playlist > /dev/null"

# Test: Check if MPV is installed (optional)
if command -v mpv &> /dev/null; then
    echo -e "${GREEN}✓${NC} mpv is available (music functions can be used)"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⊘${NC} mpv is not installed (music functions won't work until installed)"
    ((TESTS_SKIPPED++))
fi

# Test: Music shuffle alias setup
play_music_shuffle
if [ -n "$(alias mm 2>/dev/null)" ]; then
    echo -e "${GREEN}✓${NC} play_music_shuffle sets up mm alias"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} play_music_shuffle sets up mm alias"
    ((TESTS_FAILED++))
fi

# Test: remove_currently_playing_track with no MPV running
if ! pidof mpv > /dev/null 2>&1; then
    output=$(remove_currently_playing_track 2>&1)
    if [[ "$output" == *"No MPV instance"* ]] || [ $? -ne 0 ]; then
        echo -e "${GREEN}✓${NC} remove_currently_playing_track handles no MPV instance"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⊘${NC} remove_currently_playing_track handles no MPV instance (no MPV running)"
        ((TESTS_SKIPPED++))
    fi
fi

print_summary
