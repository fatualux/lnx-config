#!/bin/bash

# Optimize logger sourcing - check if already available first
if [[ -z "$__LOGGER_SOURCED" ]] && [[ -f "$BASH_CONFIG_DIR/core/logger.sh" ]]; then
    source "$BASH_CONFIG_DIR/core/logger.sh"
fi

# --- fzf Fuzzy History Search ---
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

# Interactive fzf search function (for direct execution)
fzf_search_interactive() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf not installed"
        return 1
    fi

    local selected
    selected=$(
        history |
        tac |
        sed -E 's/^ *[0-9]+ +([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} )?//' |
        fzf --height=60% --reverse --ansi \
            --prompt="History> " \
            --header="Ctrl-Y = copy  |  Enter = execute  |  Esc = cancel" \
            --bind "ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort" \
            --bind "esc:abort" \
            --preview "echo {}" \
            --preview-window=up:3:wrap:hidden
    )

    if [[ -n "$selected" ]]; then
        echo "Executing: $selected"
        eval "$selected"
    fi
}

# Only bind in interactive shells
if [[ $- == *i* ]]; then
    # Bind Ctrl-R to use fzf history search
    bind -x '"\C-r": fzf_history_search'
fi

alias f='fzf_search_interactive'
