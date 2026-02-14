#!/bin/bash

function cd-activate() {
    builtin cd "$@" || return 1

    # Activate virtual environment if available
    if [ -f ./.venv/bin/activate ]; then
        echo "🛈  Activating virtual environment (.venv)..."
        source ./.venv/bin/activate
        echo "✓  Virtual environment activated: .venv"
    elif [ -f ./.virtualenv/bin/activate ]; then
        echo "🛈  Activating virtual environment (.virtualenv)..."
        source ./.virtualenv/bin/activate
        echo "✓  Virtual environment activated: .virtualenv"
    fi

    # Source .env files if present
    if command -v source_env_files &> /dev/null; then
        source_env_files
    fi
}

# Override 'cd' command to automatically activate virtual environments
alias cd='cd-activate'
