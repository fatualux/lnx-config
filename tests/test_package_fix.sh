#!/bin/bash

# Test the package installation fix
set -euo pipefail

echo "Testing package installation fix..."

# Source the required modules
source src/logger.sh
source src/applications.sh

echo "Testing with current package list..."
if install_packages; then
    echo "✓ Package installation completed successfully"
else
    echo "✗ Package installation failed"
    exit 1
fi

echo "Package installation test completed!"
