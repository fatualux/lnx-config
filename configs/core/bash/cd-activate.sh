#!/bin/bash

function cd-activate() {
    builtin cd "$@" || return 1

    # Get the current working directory after cd
    local current_dir="$(pwd)"
    
    # Activate virtual environment if available in current directory
    if [ -f "$current_dir/.venv/bin/activate" ]; then
        echo "🛈  Activating virtual environment (.venv)..."
        source "$current_dir/.venv/bin/activate"
        echo "✓  Virtual environment activated: .venv"
    elif [ -f "$current_dir/.virtualenv/bin/activate" ]; then
        echo "🛈  Activating virtual environment (.virtualenv)..."
        source "$current_dir/.virtualenv/bin/activate"
        echo "✓  Virtual environment activated: .virtualenv"
    elif [ -f "$current_dir/venv/bin/activate" ]; then
        echo "🛈  Activating virtual environment (venv)..."
        source "$current_dir/venv/bin/activate"
        echo "✓  Virtual environment activated: venv"
    elif [ -f "$current_dir/env/bin/activate" ]; then
        echo "🛈  Activating virtual environment (env)..."
        source "$current_dir/env/bin/activate"
        echo "✓  Virtual environment activated: env"
    elif [ -d "$current_dir/.conda" ] && [ -f "$current_dir/.conda/etc/profile.d/conda.sh" ]; then
        echo "🛈  Activating conda environment (.conda)..."
        source "$current_dir/.conda/etc/profile.d/conda.sh"
        conda activate .conda
        echo "✓  Conda environment activated: .conda"
    fi

    # Source .env files if present
    if command -v source_env_files &> /dev/null; then
        source_env_files
    fi
}

# Override 'cd' command to automatically activate virtual environments
alias cd='cd-activate'
