#!/bin/bash

# Optimize logger sourcing - check if already available first
if [[ -z "$__LOGGER_SOURCED" ]] && [[ -f "$BASH_CONFIG_DIR/core/logger.sh" ]]; then
    source "$BASH_CONFIG_DIR/core/logger.sh"
fi

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

# Only bind fzf history search for interactive shells if fzf is available
if [[ $- == *i* ]] && command -v fzf >/dev/null 2>&1 && [[ -z "$FZF_HISTORY_BOUND" ]]; then
    log_debug "Configuring fzf history search for interactive shell"
    # Unbind any previous Ctrl-R
    bind -r "\C-r" 2>/dev/null
    # Bind our custom widget
    bind -x '"\C-r": fzf_history_search'
    log_info "fzf history search enabled (Ctrl-R)"
    export FZF_HISTORY_BOUND=1
fi
