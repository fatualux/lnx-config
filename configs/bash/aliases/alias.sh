#!/bin/bash
alias ls='ls -a --color=auto'
alias j="joshuto"
alias python="python3"
alias hh="vim $HISTFILE"
alias cdd="code ."
alias dkl="docker logs -f"
alias ds="docker system info"
alias c="clear"
alias co="checkout"

# Custom Function Aliases
alias lma="list_my_aliases"
alias cc="code_directory"
alias rcd="recursive_cat"
alias mm="play_music_shuffle"
alias dck="kill_docker_containers"
alias cpc="clear_python_caches"
alias rzi="remove_zone_info"
alias rcpt="remove_currently_playing_track"
alias actp="add_current_track_to_playlist"
alias dcpf="docker_container_prune_force"
alias dnpf="docker_network_prune_force"
alias rzi="remove_zone_info"
alias dc="docker_compose_wrapper"
alias dcf="docker_compose_file"
alias dsp="docker_system_prune"

# cd alias is defined in integrations/cd-activate.sh
alias tree='git log --graph --decorate --all --oneline'
alias lg='git log --graph --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%C(Yellow)%h %Cgreen%aN %C(cyan)%ad%Creset %s %C(auto)%d"'
alias clean-branches='git branch | grep -v main | xargs git branch -D'
alias st='git status'
alias co="checkout"
