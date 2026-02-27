#!/bin/bash

# Performance test for module loading optimization
set -euo pipefail

echo "Testing Module Loading Performance..."
echo "====================================="

# Test 1: Old linear array approach (simulated)
echo "Testing old linear array approach..."
time_old=0
for i in {1..100}; do
    start=$(date +%s%N)
    # Simulate linear search through array
    modules=("colors.sh" "logger.sh" "spinner.sh" "ui.sh" "prompts.sh" "backup.sh" "install.sh" "symlinks.sh" "permissions.sh" "git.sh" "applications.sh" "nixos.sh" "main.sh")
    found=false
    for module in "${modules[@]}"; do
        if [[ "$module" == "main.sh" ]]; then
            found=true
            break
        fi
    done
    end=$(date +%s%N)
    time_old=$((time_old + (end - start)))
done
echo "Old approach: $((time_old / 1000000))ms for 100 iterations"

# Test 2: New associative array approach
echo "Testing new associative array approach..."
time_new=0
declare -A module_registry
module_registry=([colors.sh]=1 [logger.sh]=1 [spinner.sh]=1 [ui.sh]=1 [prompts.sh]=1 [backup.sh]=1 [install.sh]=1 [symlinks.sh]=1 [permissions.sh]=1 [git.sh]=1 [applications.sh]=1 [nixos.sh]=1 [main.sh]=1)

for i in {1..100}; do
    start=$(date +%s%N)
    # O(1) lookup
    if [[ -n "${module_registry[main.sh]:-}" ]]; then
        found=true
    fi
    end=$(date +%s%N)
    time_new=$((time_new + (end - start)))
done
echo "New approach: $((time_new / 1000000))ms for 100 iterations"

improvement=$((time_old * 100 / time_new))
echo ""
echo "Performance improvement: ${improvement}% faster"
echo "Speedup factor: $((time_old / time_new))x"
