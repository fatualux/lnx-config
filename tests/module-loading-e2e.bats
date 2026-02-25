#!/usr/bin/env bats

# Module Loading E2E Tests for lnx-config
# Tests real-world module loading scenarios

setup() {
    export TEST_MODE=1
    cd /root/Debian/lnx-config
    
    # Create E2E test environment
    export E2E_TEST_LOG="$TEST_TEMP_DIR/e2e_test.log"
    export E2E_TEST_HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$E2E_TEST_HOME"
    
    # Mock system environment
    export HOME="$E2E_TEST_HOME"
    export USER="testuser"
    export LOG_LEVEL=0
}

teardown() {
    # Clean up E2E test artifacts
    rm -f "$E2E_TEST_LOG" 2>/dev/null || true
    rm -rf "$E2E_TEST_HOME" 2>/dev/null || true
}

@test "installer startup module loading workflow" {
    # Test the installer's module loading workflow
    local SCRIPT_DIR="$(pwd)"
    local SRC_DIR="$SCRIPT_DIR/src"
    
    # Load core modules as installer does
    for module in colors.sh logger.sh spinner.sh; do
        if [[ -f "$SRC_DIR/$module" ]]; then
            source "$SRC_DIR/$module"
        else
            echo "Warning: Required core module $SRC_DIR/$module not found, skipping..." >&2
        fi
    done
    
    # Load functional modules as installer does
    for module in ui.sh prompts.sh backup.sh install.sh symlinks.sh permissions.sh git.sh applications.sh nixos.sh main.sh; do
        if [[ -f "$SRC_DIR/$module" ]]; then
            source "$SRC_DIR/$module"
        else
            echo "Warning: Optional module $SRC_DIR/$module not found, skipping..." >&2
        fi
    done
    
    PERF_TEST_END_TIME=$(date +%s%N)
    startup_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Installer startup should complete within 3 seconds
    [[ $startup_time -lt $max_startup_time ]] || {
        echo "Installer startup too slow: ${startup_time}ns (expected < ${max_startup_time}ns)"
        return 1
    }
    
    echo "Installer startup completed in: ${startup_time}ns"
}

@test "dry-run installation module loading" {
    # Test module loading during dry-run installation
    
    local dry_run_time
    local max_dry_run_time=2000000000  # 2 seconds in nanoseconds
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Simulate dry-run mode
    export dry_run=true
    
    # Load modules and simulate dry-run workflow
    source src/colors.sh
    source src/logger.sh
    source src/spinner.sh
    source src/main.sh
    
    # Test dry-run functions that don't require actual installation
    show_welcome >/dev/null 2>&1 || true
    validate_config >/dev/null 2>&1 || true
    
    PERF_TEST_END_TIME=$(date +%s%N)
    dry_run_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Dry-run should be fast
    [[ $dry_run_time -lt $max_dry_run_time ]] || {
        echo "Dry-run too slow: ${dry_run_time}ns (expected < ${max_dry_run_time}ns)"
        return 1
    }
    
    echo "Dry-run completed in: ${dry_run_time}ns"
}

@test "help system module loading" {
    # Test module loading when displaying help
    
    local help_time
    local max_help_time=1000000000  # 1 second in nanoseconds
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Load minimal modules for help display
    source src/colors.sh
    source src/logger.sh
    
    # Test help function (if available)
    if declare -f show_help >/dev/null 2>&1; then
        show_help >/dev/null 2>&1 || true
    fi
    
    PERF_TEST_END_TIME=$(date +%s%N)
    help_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Help should be very fast
    [[ $help_time -lt $max_help_time ]] || {
        echo "Help display too slow: ${help_time}ns (expected < ${max_help_time}ns)"
        return 1
    }
    
    echo "Help displayed in: ${help_time}ns"
}

@test "configuration loading with missing modules" {
    # Test module loading when some modules are missing
    
    local missing_modules_time
    local max_missing_time=1500000000  # 1.5 seconds in nanoseconds
    
    # Temporarily move a module to simulate missing
    mv src/ui.sh src/ui.sh.bak 2>/dev/null || true
    mv src/prompts.sh src/prompts.sh.bak 2>/dev/null || true
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Load modules with missing dependencies
    source src/colors.sh
    source src/logger.sh
    source src/spinner.sh
    
    # Try to load missing modules (should handle gracefully)
    source src/ui.sh 2>/dev/null || echo "ui.sh not found, skipping..."
    source src/prompts.sh 2>/dev/null || echo "prompts.sh not found, skipping..."
    
    PERF_TEST_END_TIME=$(date +%s%N)
    missing_modules_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Missing modules should not significantly slow down loading
    [[ $missing_modules_time -lt $max_missing_time ]] || {
        echo "Missing modules handling too slow: ${missing_modules_time}ns (expected < ${max_missing_time}ns)"
        return 1
    }
    
    echo "Missing modules handled in: ${missing_modules_time}ns"
    
    # Restore modules
    mv src/ui.sh.bak src/ui.sh 2>/dev/null || true
    mv src/prompts.sh.bak src/prompts.sh 2>/dev/null || true
}

@test "concurrent module loading simulation" {
    # Test behavior when modules are loaded concurrently (simulated)
    
    local concurrent_time
    local max_concurrent_time=4000000000  # 4 seconds in nanoseconds
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Simulate concurrent access by loading modules in different orders
    local module_sets=(
        "colors.sh logger.sh spinner.sh"
        "ui.sh prompts.sh backup.sh"
        "install.sh symlinks.sh permissions.sh"
        "git.sh applications.sh nixos.sh main.sh"
    )
    
    for module_set in "${module_sets[@]}"; do
        # Load modules in background (simulated)
        (
            for module in $module_set; do
                if [[ -f "src/$module" ]]; then
                    source "src/$module" 2>/dev/null || true
                fi
            done
        ) &
        
        # Wait for background process to complete
        wait
    done
    
    PERF_TEST_END_TIME=$(date +%s%N)
    concurrent_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Concurrent simulation should complete within reasonable time
    [[ $concurrent_time -lt $max_concurrent_time ]] || {
        echo "Concurrent loading simulation too slow: ${concurrent_time}ns (expected < ${max_concurrent_time}ns)"
        return 1
    }
    
    echo "Concurrent loading simulation completed in: ${concurrent_time}ns"
}

@test "module loading with environment variables" {
    # Test module loading with various environment variable settings
    
    local env_time
    local max_env_time=2000000000  # 2 seconds in nanoseconds
    
    # Set various environment variables
    export LOG_LEVEL=0
    export LOG_TIMESTAMP=true
    export SCRIPT_DIR="/root/Debian/lnx-config"
    export SRC_DIR="$SCRIPT_DIR/src"
    export TEST_MODE=1
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Load modules with environment variables
    source src/colors.sh
    source src/logger.sh
    source src/spinner.sh
    source src/ui.sh
    
    # Test environment-dependent functionality
    log_info "Test message" >/dev/null 2>&1 || true
    
    PERF_TEST_END_TIME=$(date +%s%N)
    env_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Environment variable handling should not impact performance
    [[ $env_time -lt $max_env_time ]] || {
        echo "Environment variable handling too slow: ${env_time}ns (expected < ${max_env_time}ns)"
        return 1
    }
    
    echo "Environment variable handling completed in: ${env_time}ns"
}

@test "module loading memory pressure" {
    # Test module loading under memory pressure (simulated)
    
    local memory_pressure_time
    local max_memory_pressure_time=3000000000  # 3 seconds in nanoseconds
    
    # Simulate memory pressure by creating temporary data
    local temp_data="$TEST_TEMP_DIR/temp_data"
    dd if=/dev/zero of="$temp_data" bs=1M count=10 2>/dev/null || true
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Load modules under memory pressure
    source src/colors.sh
    source src/logger.sh
    source src/spinner.sh
    source src/main.sh
    
    PERF_TEST_END_TIME=$(date +%s%N)
    memory_pressure_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Memory pressure should not significantly impact loading
    [[ $memory_pressure_time -lt $max_memory_pressure_time ]] || {
        echo "Memory pressure handling too slow: ${memory_pressure_time}ns (expected < ${max_memory_pressure_time}ns)"
        return 1
    }
    
    echo "Memory pressure handling completed in: ${memory_pressure_time}ns"
    
    # Clean up
    rm -f "$temp_data" 2>/dev/null || true
}

@test "module loading error recovery" {
    # Test module loading error recovery scenarios
    
    local error_recovery_time
    local max_error_recovery_time=2500000000  # 2.5 seconds in nanoseconds
    
    # Create a module with syntax error
    local error_module="$TEST_TEMP_DIR/error_module.sh"
    cat > "$error_module" << 'EOF'
#!/bin/bash
# Module with syntax error
echo "Loading error module..."
invalid_syntax_here
EOF
    
    PERF_TEST_START_TIME=$(date +%s%N)
    
    # Load modules with error recovery
    source src/colors.sh
    source src/logger.sh
    
    # Try to load error module (should fail gracefully)
    source "$error_module" 2>/dev/null || echo "Error module failed, continuing..."
    
    # Continue loading other modules
    source src/spinner.sh
    source src/ui.sh
    
    PERF_TEST_END_TIME=$(date +%s%N)
    error_recovery_time=$((PERF_TEST_END_TIME - PERF_TEST_START_TIME))
    
    # Error recovery should not significantly impact performance
    [[ $error_recovery_time -lt $max_error_recovery_time ]] || {
        echo "Error recovery too slow: ${error_recovery_time}ns (expected < ${max_error_recovery_time}ns)"
        return 1
    }
    
    echo "Error recovery completed in: ${error_recovery_time}ns"
    
    # Clean up
    rm -f "$error_module" 2>/dev/null || true
}
