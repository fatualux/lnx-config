# ==============================
# History search navigation
# ==============================

# Only bind in interactive shells
if [[ $- == *i* ]]; then
    # Search history using current line as a prefix
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
    bind '"\eOA": history-search-backward'
    bind '"\eOB": history-search-forward'

    # Common alternatives
    bind '"\C-p": history-search-backward'
    bind '"\C-n": history-search-forward'
    bind '"\ep": history-search-backward'
    bind '"\en": history-search-forward'

    # PageUp/PageDown (tmux/screen/xterm variants)
    bind '"\e[5~": history-search-backward'
    bind '"\e[6~": history-search-forward'

    # Preserve cursor position during history search
    bind "set history-preserve-point on"
fi
