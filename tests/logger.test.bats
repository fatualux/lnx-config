#!/usr/bin/env bats

# Load test helpers and logger
load test_helper
source "$SCRIPT_DIR/src/logger.sh"

@test "logger: defines color variables" {
    [ -n "$COLOR_RED" ]
    [ -n "$COLOR_GREEN" ]
    [ -n "$COLOR_YELLOW" ]
    [ -n "$COLOR_BLUE" ]
    [ -n "$COLOR_MAGENTA" ]
    [ -n "$COLOR_CYAN" ]
    [ -n "$COLOR_WHITE" ]
    [ -n "$COLOR_BOLD" ]
    [ -n "$NC" ]
}

@test "logger: log_info outputs info message" {
    run log_info "Test info message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test info message" ]]
}

@test "logger: log_success outputs success message" {
    run log_success "Test success message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test success message" ]]
}

@test "logger: log_warn outputs warning message" {
    run log_warn "Test warning message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test warning message" ]]
}

@test "logger: log_error outputs error message" {
    run log_error "Test error message"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test error message" ]]
}

@test "logger: log_section outputs section header" {
    run log_section "Test Section"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test Section" ]]
}

@test "logger: handles empty messages gracefully" {
    run log_info ""
    [ "$status" -eq 0 ]
}

@test "logger: handles special characters in messages" {
    run log_info "Message with special chars: !@#$%^&*()"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Message with special chars" ]]
}
