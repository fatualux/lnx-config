#!/bin/bash

# Optimize logger sourcing - check if already available first
if [[ -z "${__LOGGER_SOURCED:-}" ]] && [[ -f "$BASH_CONFIG_DIR/core/logger.sh" ]]; then
    source "$BASH_CONFIG_DIR/core/logger.sh"
fi

# --- Clean & Deduplicate on Exit ---
__bash_history_cleanup() {
    if command -v log_debug >/dev/null 2>&1; then
        log_debug "Cleaning up bash history on exit"
    fi
    history -a
    awk '!seen[$0]++' "$HISTFILE" | tail -n "$HISTFILESIZE" > "${HISTFILE}.tmp" && mv "${HISTFILE}.tmp" "$HISTFILE"
    if command -v log_debug >/dev/null 2>&1; then
        log_debug "History cleanup complete"
    fi
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
  if command -v log_func_start >/dev/null 2>&1; then
    log_func_start "fzf_history_search"
  fi
  if ! command -v fzf >/dev/null 2>&1; then
    if command -v log_warn >/dev/null 2>&1; then
      log_warn "fzf not installed, using default Ctrl-R"
    fi
    bind '"\C-r": reverse-search-history'
    if command -v log_func_end >/dev/null 2>&1; then
      log_func_end "fzf_history_search"
    fi
    return 127
  fi

  if command -v log_debug >/dev/null 2>&1; then
    log_debug "Starting fzf history search"
  fi
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
    if command -v log_debug >/dev/null 2>&1; then
      log_debug "Selected command: $selected"
    fi
    READLINE_LINE="$selected"
    READLINE_POINT=${#READLINE_LINE}
  else
    if command -v log_debug >/dev/null 2>&1; then
      log_debug "No command selected"
    fi
  fi
  if command -v log_func_end >/dev/null 2>&1; then
    log_func_end "fzf_history_search"
  fi
}

# Only bind fzf history search for interactive shells if fzf is available
if [[ $- == *i* ]] && command -v fzf >/dev/null 2>&1 && [[ -z "$FZF_HISTORY_BOUND" ]]; then
  if command -v log_debug >/dev/null 2>&1; then
    log_debug "Configuring fzf history search for interactive shell"
  fi
  # Unbind any previous Ctrl-R
  bind -r "\C-r" 2>/dev/null
  # Bind our custom widget
  bind -x '"\C-r": fzf_history_search'
  if command -v log_info >/dev/null 2>&1; then
    log_info "fzf history search enabled (Ctrl-R)"
  fi
  export FZF_HISTORY_BOUND=1
fi
