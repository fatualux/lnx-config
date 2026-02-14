#!/bin/bash

# Source logger with multiple fallback paths and guard against re-sourcing
if [[ -z "$__LOGGER_SOURCED" ]]; then
    _source_logger() {
        local logger_paths=(
            "${BASH_SOURCE%/*}/logger.sh"
            "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
            "$HOME/.config/bash/logger.sh"
            "$HOME/.bashrc.d/logger.sh"
            "/etc/bash/logger.sh"
            "./logger.sh"
        )
        
        for path in "${logger_paths[@]}"; do
            if [ -f "$path" ]; then
                source "$path"
                return 0
            fi
        done
        
        # Fallback: create stub functions if logger not found
        echo "Warning: logger.sh not found in standard paths. Logging disabled." >&2
        log_func_start() { :; }
        log_func_end() { :; }
        log_debug() { :; }
        log_info() { echo "$@"; }
        log_warn() { echo "Warning: $@" >&2; }
        return 1
    }
    
    _source_logger
fi

# --- Clean & Deduplicate on Exit ---
__bash_history_cleanup() {
    log_debug "Cleaning up bash history on exit"
    history -a
    awk '!seen[$0]++' "$HISTFILE" | tail -n "$HISTFILESIZE" > "${HISTFILE}.tmp" && mv "${HISTFILE}.tmp" "$HISTFILE"
    log_debug "History cleanup complete"
}

# Safely integrate with PROMPT_COMMAND
if [[ -n "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="__bash_history_sync; $PROMPT_COMMAND"
else
    PROMPT_COMMAND="__bash_history_sync"
fi
trap '__bash_history_cleanup' EXIT

# --- fzf Fuzzy History Search (Ctrl-R) ---
fzf_history_search() {
  log_func_start "fzf_history_search"
  if ! command -v fzf >/dev/null 2>&1; then
    log_warn "fzf not installed, using default Ctrl-R"
    bind '"\C-r": reverse-search-history'
    log_func_end "fzf_history_search"
    return 127
  fi

  log_debug "Starting fzf history search"
  local selected
  selected=$(
    # Show only command text (remove numbering and timestamps)
    history |
    tac |
    sed -E 's/^ *[0-9]+ +([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} )?//' |
    fzf --height=60% --reverse --ansi \
        --prompt="History> " \
        --header="Ctrl-Y = copy  |  Enter = paste to prompt" \
        --bind "ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort" \
        --preview "echo {}" \
        --preview-window=up:3:wrap:hidden
  )

  if [[ -n "$selected" ]]; then
    log_debug "Selected command: $selected"
    READLINE_LINE="$selected"
    READLINE_POINT=${#READLINE_LINE}
  else
    log_debug "No command selected"
  fi
  log_func_end "fzf_history_search"
}

# --- Bind Ctrl-R to fzf (interactive shells only) ---
if [[ $- == *i* ]]; then
  log_debug "Configuring fzf history search for interactive shell"
  # Unbind any previous Ctrl-R
  bind -r "\C-r" 2>/dev/null
  # Bind our custom widget
  bind -x '"\C-r": fzf_history_search'
  log_info "fzf history search enabled (Ctrl-R)"
fi
