#!/bin/bash

function cd-activate() {
    export CD_ACTIVATING=1
    builtin cd "$@" || return 1

    # Get the current working directory after cd
    local current_dir="$(pwd)"
    
    # Activate virtual environment if available in current directory
    if [ -f "$current_dir/.venv/bin/activate" ]; then
        log_info "Activating virtual environment (.venv)..."
        source "$current_dir/.venv/bin/activate"
        log_success "Virtual environment activated: .venv"
    elif [ -f "$current_dir/.virtualenv/bin/activate" ]; then
        log_info "Activating virtual environment (.virtualenv)..."
        source "$current_dir/.virtualenv/bin/activate"
        log_success "Virtual environment activated: .virtualenv"
    elif [ -f "$current_dir/venv/bin/activate" ]; then
        log_info "Activating virtual environment (venv)..."
        source "$current_dir/venv/bin/activate"
        log_success "Virtual environment activated: venv"
    elif [ -f "$current_dir/env/bin/activate" ]; then
        log_info "Activating virtual environment (env)..."
        source "$current_dir/env/bin/activate"
        log_success "Virtual environment activated: env"
    elif [ -d "$current_dir/.conda" ] && [ -f "$current_dir/.conda/etc/profile.d/conda.sh" ]; then
        log_info "Activating conda environment (.conda)..."
        source "$current_dir/.conda/etc/profile.d/conda.sh"
        conda activate .conda
        log_success "Conda environment activated: .conda"
    fi

    # Source .env files if present
    if command -v source_env_files &> /dev/null; then
        source_env_files
    fi
    
    unset CD_ACTIVATING
}

# Function to activate environments on shell startup and prompt changes
activate_on_prompt() {
    # Only run if we're not in the middle of a cd operation
    if [ "${CD_ACTIVATING:-0}" != "1" ]; then
        local current_dir="$(pwd)"
        
        # Activate virtual environment if available in current directory
        if [ -f "$current_dir/.venv/bin/activate" ]; then
            if [ -z "$VIRTUAL_ENV" ] || [ "$VIRTUAL_ENV" != "$current_dir/.venv" ]; then
                log_info "Activating virtual environment (.venv)..."
                source "$current_dir/.venv/bin/activate"
                log_success "Virtual environment activated: .venv"
            fi
        elif [ -f "$current_dir/.virtualenv/bin/activate" ]; then
            if [ -z "$VIRTUAL_ENV" ] || [ "$VIRTUAL_ENV" != "$current_dir/.virtualenv" ]; then
                log_info "Activating virtual environment (.virtualenv)..."
                source "$current_dir/.virtualenv/bin/activate"
                log_success "Virtual environment activated: .virtualenv"
            fi
        elif [ -f "$current_dir/venv/bin/activate" ]; then
            if [ -z "$VIRTUAL_ENV" ] || [ "$VIRTUAL_ENV" != "$current_dir/venv" ]; then
                log_info "Activating virtual environment (venv)..."
                source "$current_dir/venv/bin/activate"
                log_success "Virtual environment activated: venv"
            fi
        elif [ -f "$current_dir/env/bin/activate" ]; then
            if [ -z "$VIRTUAL_ENV" ] || [ "$VIRTUAL_ENV" != "$current_dir/env" ]; then
                log_info "Activating virtual environment (env)..."
                source "$current_dir/env/bin/activate"
                log_success "Virtual environment activated: env"
            fi
        elif [ -d "$current_dir/.conda" ] && [ -f "$current_dir/.conda/etc/profile.d/conda.sh" ]; then
            if [ -z "$CONDA_DEFAULT_ENV" ] || [ "$CONDA_DEFAULT_ENV" != ".conda" ]; then
                log_info "Activating conda environment (.conda)..."
                source "$current_dir/.conda/etc/profile.d/conda.sh"
                conda activate .conda
                log_success "Conda environment activated: .conda"
            fi
        fi

        # Source .env files if present
        if command -v source_env_files &> /dev/null; then
            source_env_files
        fi
    fi
}

# Set up PROMPT_COMMAND to run activation on every prompt
if [ -z "${PROMPT_COMMAND:-}" ]; then
    PROMPT_COMMAND="activate_on_prompt"
else
    PROMPT_COMMAND="$PROMPT_COMMAND; activate_on_prompt"
fi

# Run activation on shell startup
activate_on_prompt
