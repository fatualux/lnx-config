#!/usr/bin/env bash

# Test helper for loading install.sh functions
# This allows tests to access functions from install.sh

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source the install.sh file to get access to functions
if [[ -f "$PROJECT_ROOT/src/install.sh" ]]; then
    source "$PROJECT_ROOT/src/install.sh"
else
    echo "ERROR: Could not find install.sh at $PROJECT_ROOT/src/install.sh" >&2
    exit 1
fi

# Set VERSION if not already set
: "${VERSION:=2.6.7}"
