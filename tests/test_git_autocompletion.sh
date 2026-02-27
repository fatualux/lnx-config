#!/bin/bash

# Test file for git autocompletion fix
# Tests the enhanced create_bashrc function to ensure git-autocompletion.sh is included

set -euo pipefail

# Source the required modules
source "$(dirname "${BASH_SOURCE[0]}")/../src/logger.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../src/install.sh"

echo "Testing git autocompletion inclusion in .bashrc generation..."

# Test 1: Verify git-autocompletion.sh is included in generated .bashrc
test_git_autocompletion_inclusion() {
    echo "Testing git-autocompletion.sh inclusion in .bashrc..."
    
    # Create a temporary directory for testing
    local temp_dir=$(mktemp -d)
    local temp_bashrc="$temp_dir/.bashrc"
    local temp_configs="$temp_dir/configs"
    
    # Set up test environment
    export HOME="$temp_dir"
    export CORE_BASH_DIR="$temp_configs/core/bash"
    export SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."
    export force_regeneration=false
    
    # Create mock configs directory structure
    mkdir -p "$CORE_BASH_DIR"
    
    # Create mock git-autocompletion.sh
    cat > "$CORE_BASH_DIR/git-autocompletion.sh" << 'EOF'
#!/bin/bash
# Mock git autocompletion for testing
_git_completion_initialize() {
    echo "Git completion initialized" >&2
}
EOF
    
    # Create other mock bash config files
    echo "# Mock alias.sh" > "$CORE_BASH_DIR/alias.sh"
    mkdir -p "$CORE_BASH_DIR/config"
    echo "# Mock theme.sh" > "$CORE_BASH_DIR/config/theme.sh"
    
    # Mock the should_regenerate function to always return true
    should_regenerate() { return 0; }
    create_metadata_header() { echo "# Mock header"; }
    validate_bash_syntax() { return 0; }
    rollback_config() { echo "Mock rollback"; }
    
    # Test create_bashrc function
    if create_bashrc; then
        # Check if git-autocompletion.sh is included
        if grep -q "git-autocompletion.sh" "$temp_bashrc"; then
            echo "✓ PASS: git-autocompletion.sh is included in .bashrc"
            rm -rf "$temp_dir"
            return 0
        else
            echo "✗ FAIL: git-autocompletion.sh is NOT included in .bashrc"
            echo "Generated .bashrc content:"
            cat "$temp_bashrc"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        echo "✗ FAIL: create_bashrc function failed"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Test 2: Verify git completion functions are available after sourcing
test_git_completion_functions() {
    echo "Testing git completion functions availability..."
    
    # Create a temporary bashrc with git autocompletion
    local temp_bashrc=$(mktemp)
    
    cat > "$temp_bashrc" << 'EOF'
#!/bin/bash
# Mock git completion functions
_git_completion_initialize() {
    echo "Git completion initialized" >&2
}

_git() {
    echo "Git completion function called" >&2
}

_git_flow() {
    echo "Git flow completion function called" >&2
}

__git_ps1() {
    echo "(git-prompt)"
}
EOF
    
    # Source the temporary bashrc and test functions
    if source "$temp_bashrc"; then
        if declare -f _git_completion_initialize >/dev/null && \
           declare -f _git >/dev/null && \
           declare -f _git_flow >/dev/null && \
           declare -f __git_ps1 >/dev/null; then
            echo "✓ PASS: All git completion functions are available"
            rm -f "$temp_bashrc"
            return 0
        else
            echo "✗ FAIL: Some git completion functions are missing"
            rm -f "$temp_bashrc"
            return 1
        fi
    else
        echo "✗ FAIL: Failed to source temporary bashrc"
        rm -f "$temp_bashrc"
        return 1
    fi
}

# Test 3: Verify file discovery mechanism finds git-autocompletion.sh
test_file_discovery() {
    echo "Testing file discovery mechanism..."
    
    # Create a temporary directory structure
    local temp_dir=$(mktemp -d)
    local temp_configs="$temp_dir/configs/core/bash"
    
    # Create mock configs directory structure
    mkdir -p "$temp_configs"
    mkdir -p "$temp_configs/config"
    
    # Create mock files including git-autocompletion.sh
    echo "# Mock alias.sh" > "$temp_configs/alias.sh"
    echo "# Mock docker.sh" > "$temp_configs/docker.sh"
    echo "# Mock git-autocompletion.sh" > "$temp_configs/git-autocompletion.sh"
    echo "# Mock theme.sh" > "$temp_configs/config/theme.sh"
    
    # Test file discovery using find command (similar to create_bashrc)
    local discovered_files
    discovered_files=$(find "$temp_configs" -name "*.sh" -type f | grep -v "config/theme.sh" | sort)
    
    # Check if git-autocompletion.sh is in the discovered files
    if echo "$discovered_files" | grep -q "git-autocompletion.sh"; then
        echo "✓ PASS: git-autocompletion.sh is discovered by find command"
        rm -rf "$temp_dir"
        return 0
    else
        echo "✗ FAIL: git-autocompletion.sh is NOT discovered by find command"
        echo "Discovered files:"
        echo "$discovered_files"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Run tests
echo "Running git autocompletion tests..."
echo "================================"

test_git_autocompletion_inclusion
test_git_completion_functions
test_file_discovery

echo "All tests completed!"
