#!/usr/bin/env bats

# Module Loading Baseline Tests
# Establish current performance metrics before optimization

setup() {
    export TEST_MODE=1
    cd /root/Debian/lnx-config
    
    # Create baseline test environment
    export BASELINE_TEST_LOG="$TEST_TEMP_DIR/baseline_test.log"
    export BASELINE_RESULTS="$TEST_TEMP_DIR/baseline_results.json"
    
    # Initialize results structure
    echo '{"module_times": {}, "memory_usage": {}, "total_time": 0}' > "$BASELINE_RESULTS"
    
    # Source installer to get load_module functions
    source installer.sh >/dev/null 2>&1 || true
}

teardown() {
    # Clean up baseline test artifacts
    rm -f "$BASELINE_TEST_LOG" "$BASELINE_RESULTS" 2>/dev/null || true
}

# Helper function to time module loading
time_module_loading() {
    local modules=("$@")
    local start_time end_time duration
    
    start_time=$(date +%s%N)
    
    for module in "${modules[@]}"; do
        if [[ -f "src/$module" ]]; then
            source "src/$module" 2>/dev/null || true
        fi
    done
    
    end_time=$(date +%s%N)
    duration=$((end_time - start_time))
    echo "$duration"
}

# Helper function to measure memory usage
measure_memory_usage() {
    local command="$1"
    local memory_before memory_after
    
    memory_before=$(ps -o rss= -p $$ | tr -d ' ')
    
    eval "$command" 2>/dev/null || true
    
    memory_after=$(ps -o rss= -p $$ | tr -d ' ')
    echo $((memory_after - memory_before))
}

@test "baseline core modules loading time" {
    # Establish baseline for core modules loading
    local core_modules=("colors.sh" "logger.sh" "spinner.sh")
    local duration
    
    duration=$(time_module_loading "${core_modules[@]}")
    
    # Record baseline
    echo "{\"core_modules\": $duration}" >> "$BASELINE_RESULTS"
    
    # Core modules should currently take around 0.5 seconds
    # This test will establish the baseline, not enforce a target
    [[ $duration -gt 0 ]] || {
        echo "Core modules loading time should be positive"
        return 1
    }
    
    echo "Baseline core modules loading time: ${duration}ns"
}

@test "baseline functional modules loading time" {
    # Establish baseline for functional modules loading
    local functional_modules=("ui.sh" "prompts.sh" "backup.sh" "install.sh" "symlinks.sh" "permissions.sh" "git.sh" "applications.sh" "nixos.sh" "main.sh")
    local duration
    
    duration=$(time_module_loading "${functional_modules[@]}")
    
    # Record baseline
    echo "{\"functional_modules\": $duration}" >> "$BASELINE_RESULTS"
    
    # Functional modules should currently take around 2 seconds
    [[ $duration -gt 0 ]] || {
        echo "Functional modules loading time should be positive"
        return 1
    }
    
    echo "Baseline functional modules loading time: ${duration}ns"
}

@test "baseline complete installer startup time" {
    # Establish baseline for complete installer startup
    local startup_time
    local all_modules=("colors.sh" "logger.sh" "spinner.sh" "ui.sh" "prompts.sh" "backup.sh" "install.sh" "symlinks.sh" "permissions.sh" "git.sh" "applications.sh" "nixos.sh" "main.sh")
    
    startup_time=$(time_module_loading "${all_modules[@]}")
    
    # Record baseline
    echo "{\"complete_startup\": $startup_time}" >> "$BASELINE_RESULTS"
    
    # Complete startup should currently take around 3 seconds
    [[ $startup_time -gt 0 ]] || {
        echo "Complete startup time should be positive"
        return 1
    }
    
    echo "Baseline complete startup time: ${startup_time}ns"
}

@test "baseline memory usage during loading" {
    # Establish baseline for memory usage
    local memory_usage
    local core_modules=("colors.sh" "logger.sh" "spinner.sh")
    
    memory_usage=$(measure_memory_usage "time_module_loading ${core_modules[*]}")
    memory_usage=$(echo "$memory_usage" | tr -d ' \n\r')  # Clean up the value
    
    # Record baseline
    echo "{\"memory_usage\": $memory_usage}" >> "$BASELINE_RESULTS"
    
    # Memory usage should be measurable (can be 0 or positive)
    [[ $memory_usage -ge 0 ]] || {
        echo "Memory usage should be non-negative, got: $memory_usage"
        return 1
    }
    
    echo "Baseline memory usage: ${memory_usage}KB"
}

@test "baseline dependency resolution time" {
    # Establish baseline for dependency resolution
    local resolution_time
    local start_time end_time
    
    start_time=$(date +%s%N)
    
    # Simulate dependency resolution (checking for colors.sh)
    local color_paths=(
        "${SCRIPT_DIR:-$(pwd)}/src/colors.sh"
        "$HOME/.config/bash/colors.sh"
        "$HOME/.bashrc.d/colors.sh"
        "/etc/bash/colors.sh"
        "./colors.sh"
    )
    
    for path in "${color_paths[@]}"; do
        [[ -f "$path" ]] || true
    done
    
    end_time=$(date +%s%N)
    resolution_time=$((end_time - start_time))
    
    # Record baseline
    echo "{\"dependency_resolution\": $resolution_time}" >> "$BASELINE_RESULTS"
    
    # Dependency resolution should be fast but measurable
    [[ $resolution_time -gt 0 ]] || {
        echo "Dependency resolution time should be positive"
        return 1
    }
    
    echo "Baseline dependency resolution time: ${resolution_time}ns"
}

@test "baseline module dependency analysis" {
    # Analyze current module dependencies
    local dependencies_file="$BATS_TMPDIR/module_dependencies.txt"
    
    # Check which modules depend on others
    echo "Analyzing module dependencies..." > "$dependencies_file"
    
    # Check for color dependencies
    if grep -q "COLOR_" src/logger.sh 2>/dev/null; then
        echo "logger.sh depends on colors.sh" >> "$dependencies_file"
    fi
    
    # Check for logger dependencies
    if grep -q "log_" src/ui.sh 2>/dev/null; then
        echo "ui.sh depends on logger.sh" >> "$dependencies_file"
    fi
    
    # Check for spinner dependencies
    if grep -q "spinner_" src/main.sh 2>/dev/null; then
        echo "main.sh depends on spinner.sh" >> "$dependencies_file"
    fi
    
    # Record dependency analysis
    echo "{\"dependency_analysis\": \"$(cat "$dependencies_file")\"}" >> "$BASELINE_RESULTS"
    
    # Dependency analysis should produce results
    [[ -s "$dependencies_file" ]] || {
        echo "Dependency analysis should produce results"
        return 1
    }
    
    echo "Baseline dependency analysis completed"
}

@test "baseline bottleneck identification" {
    # Identify current bottlenecks
    local bottleneck_file="$BATS_TMPDIR/bottlenecks.txt"
    
    echo "Identifying performance bottlenecks..." > "$bottleneck_file"
    
    # Test individual module loading times
    local all_modules=("colors.sh" "logger.sh" "spinner.sh" "ui.sh" "prompts.sh" "backup.sh" "install.sh" "symlinks.sh" "permissions.sh" "git.sh" "applications.sh" "nixos.sh" "main.sh")
    local slowest_module=""
    local slowest_time=0
    
    for module in "${all_modules[@]}"; do
        if [[ -f "src/$module" ]]; then
            local module_time
            module_time=$(time_module_loading "$module")
            
            echo "$module: ${module_time}ns" >> "$bottleneck_file"
            
            if [[ $module_time -gt $slowest_time ]]; then
                slowest_time=$module_time
                slowest_module=$module
            fi
        fi
    done
    
    # Record bottleneck analysis
    echo "{\"slowest_module\": \"$slowest_module\", \"slowest_time\": $slowest_time}" >> "$BASELINE_RESULTS"
    
    # Should identify bottlenecks
    [[ -n "$slowest_module" ]] || {
        echo "Should identify at least one module as slowest"
        return 1
    }
    
    echo "Baseline bottleneck identification completed"
    echo "Slowest module: $slowest_module (${slowest_time}ns)"
}
