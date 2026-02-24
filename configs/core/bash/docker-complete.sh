#!/bin/bash
# ============================================================================
# Optimized Docker Completion Module
# ============================================================================
# Features:
#   - Lazy loading of Docker resources
#   - Smart caching for containers, images, networks
#   - Minimal external calls for performance
#   - Support for both Docker and Docker Compose

# Prevent multiple loading
if [[ -n "$_DOCKER_COMPLETION_LOADED" ]]; then
    return 0
fi
_DOCKER_COMPLETION_LOADED=1

# ============================================================================
# Docker Resource Caching
# ============================================================================

_docker_cache_get() {
    local resource="$1"
    local cache_key="docker_${resource}"
    _completion_cache_get "$cache_key"
}

_docker_cache_set() {
    local resource="$1"
    local data="$2"
    local cache_key="docker_${resource}"
    _completion_cache_set "$cache_key" "$data"
}

_docker_get_containers() {
    if ! _docker_cache_get "containers"; then
        local containers
        containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null | sort -u)
        echo "$containers" | _docker_cache_set "containers"
    fi
}

_docker_get_images() {
    if ! _docker_cache_get "images"; then
        local images
        images=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | \
            grep -v "<none>" | sort -u)
        echo "$images" | _docker_cache_set "images"
    fi
}

_docker_get_networks() {
    if ! _docker_cache_get "networks"; then
        local networks
        networks=$(docker network ls --format "{{.Name}}" 2>/dev/null | sort -u)
        echo "$networks" | _docker_cache_set "networks"
    fi
}

_docker_get_volumes() {
    if ! _docker_cache_get "volumes"; then
        local volumes
        volumes=$(docker volume ls --format "{{.Name}}" 2>/dev/null | sort -u)
        echo "$volumes" | _docker_cache_set "volumes"
    fi
}

_docker_get_services() {
    if ! _docker_cache_get "services"; then
        local services
        services=$(docker-compose config --services 2>/dev/null | sort -u)
        echo "$services" | _docker_cache_set "services"
    fi
}

# ============================================================================
# Docker Command Completions
# ============================================================================

_docker_complete_containers() {
    local cur="$1"
    _docker_get_containers
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

_docker_complete_images() {
    local cur="$1"
    _docker_get_images
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

_docker_complete_networks() {
    local cur="$1"
    _docker_get_networks
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

_docker_complete_volumes() {
    local cur="$1"
    _docker_get_volumes
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

_docker_complete_services() {
    local cur="$1"
    _docker_get_services
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

# ============================================================================
# Docker Subcommand Completions
# ============================================================================

_docker_complete_run() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -d|--detach)
            COMPREPLY=()
            return
            ;;
        -i|--interactive|-t|--tty)
            COMPREPLY=()
            return
            ;;
        -p|--publish)
            COMPREPLY=( $(compgen -W "80:80 443:443 3000:3000 8080:8080" -- "$cur") )
            return
            ;;
        -v|--volume)
            _docker_complete_volumes "$cur"
            return
            ;;
        --network)
            _docker_complete_networks "$cur"
            return
            ;;
        --name)
            COMPREPLY=()
            return
            ;;
    esac
    
    # Complete images for run command
    _docker_complete_images "$cur"
}

_docker_complete_exec() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -i|--interactive|-t|--tty)
            COMPREPLY=()
            return
            ;;
    esac
    
    # Complete containers for exec command
    _docker_complete_containers "$cur"
}

_docker_complete_rm() {
    local cur="$1"
    _docker_complete_containers "$cur"
}

_docker_complete_rmi() {
    local cur="$1"
    _docker_complete_images "$cur"
}

_docker_complete_stop() {
    local cur="$1"
    _docker_complete_containers "$cur"
}

_docker_complete_start() {
    local cur="$1"
    _docker_complete_containers "$cur"
}

_docker_complete_logs() {
    local cur="$1"
    _docker_complete_containers "$cur"
}

# ============================================================================
# Docker Compose Completions
# ============================================================================

_docker_compose_complete_up() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        --scale)
            _docker_get_services
            COMPREPLY=( $(compgen -S "=" -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    _docker_get_services
    COMPREPLY=( $(compgen -W "$(cat) --build --detach --force-recreate --no-build --help" -- "$cur") )
}

_docker_compose_complete_down() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        --rmi)
            COMPREPLY=( $(compgen -W "all local" -- "$cur") )
            return
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "--rmi --volumes --remove-orphans --help" -- "$cur") )
}

_docker_compose_complete_ps() {
    local cur="$1"
    _docker_get_services
    COMPREPLY=( $(compgen -W "$(cat) --services --help" -- "$cur") )
}

_docker_compose_complete_logs() {
    local cur="$1"
    _docker_get_services
    COMPREPLY=( $(compgen -W "$(cat) --follow --tail --help" -- "$cur") )
}

_docker_compose_complete_exec() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -i|--interactive|-t|--tty)
            COMPREPLY=()
            return
            ;;
    esac
    
    _docker_get_services
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

# ============================================================================
# Main Docker Completion Function
# ============================================================================

_docker_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Handle Docker subcommands
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=( $(compgen -W "
            build commit cp create diff events exec export history images 
            import info inspect kill load login logout logs network pause 
            port ps pull push rename restart rm rmi run save search 
            service start stats stop tag top unpause update version volume wait
            --help
        " -- "$cur") )
        return
    fi
    
    local subcmd="${COMP_WORDS[1]}"
    
    # Option completion for any subcommand
    if [[ "$cur" == -* ]]; then
        _completion_complete_with_cache "docker $subcmd" "docker_${subcmd}_opts" "_extract_docker_options" "$cur"
        return
    fi
    
    # Subcommand-specific completion
    case "$subcmd" in
        run)
            _docker_complete_run "$cur" "$prev"
            ;;
        exec)
            _docker_complete_exec "$cur" "$prev"
            ;;
        rm)
            _docker_complete_rm "$cur"
            ;;
        rmi)
            _docker_complete_rmi "$cur"
            ;;
        stop)
            _docker_complete_stop "$cur"
            ;;
        start)
            _docker_complete_start "$cur"
            ;;
        restart)
            _docker_complete_restart "$cur"
            ;;
        logs)
            _docker_complete_logs "$cur"
            ;;
        network)
            _docker_complete_network "$cur" "$prev"
            ;;
        volume)
            _docker_complete_volume "$cur" "$prev"
            ;;
        *)
            # Default to file completion
            _completion_complete_files "$cur"
            ;;
    esac
}

_docker_complete_network() {
    local cur="$1"
    local prev="$2"
    
    if (( COMP_CWORD == 2 )); then
        COMPREPLY=( $(compgen -W "create connect disconnect inspect ls prune rm" -- "$cur") )
        return
    fi
    
    local netcmd="${COMP_WORDS[2]}"
    case "$netcmd" in
        create|rm)
            COMPREPLY=()
            ;;
        connect|disconnect|inspect)
            _docker_complete_networks "$cur"
            ;;
        *)
            _completion_complete_files "$cur"
            ;;
    esac
}

_docker_complete_volume() {
    local cur="$1"
    local prev="$2"
    
    if (( COMP_CWORD == 2 )); then
        COMPREPLY=( $(compgen -W "create inspect ls prune rm" -- "$cur") )
        return
    fi
    
    local volcmd="${COMP_WORDS[2]}"
    case "$volcmd" in
        create|rm)
            COMPREPLY=()
            ;;
        inspect)
            _docker_complete_volumes "$cur"
            ;;
        *)
            _completion_complete_files "$cur"
            ;;
    esac
}

# ============================================================================
# Docker Compose Completion Function
# ============================================================================

_docker_compose_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Handle Docker Compose subcommands
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=( $(compgen -W "
            build config create down events exec help kill logs pause 
            port ps pull push restart rm run scale start stop top unpause up version
        " -- "$cur") )
        return
    fi
    
    local subcmd="${COMP_WORDS[1]}"
    
    # Option completion for any subcommand
    if [[ "$cur" == -* ]]; then
        _completion_complete_with_cache "docker-compose $subcmd" "docker_compose_${subcmd}_opts" "_extract_docker_compose_options" "$cur"
        return
    fi
    
    # Subcommand-specific completion
    case "$subcmd" in
        up)
            _docker_compose_complete_up "$cur" "$prev"
            ;;
        down)
            _docker_compose_complete_down "$cur" "$prev"
            ;;
        ps)
            _docker_compose_complete_ps "$cur" "$prev"
            ;;
        logs)
            _docker_compose_complete_logs "$cur" "$prev"
            ;;
        exec)
            _docker_compose_complete_exec "$cur" "$prev"
            ;;
        stop|start|restart|kill)
            _docker_get_services
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            ;;
        *)
            # Default to file completion
            _completion_complete_files "$cur"
            ;;
    esac
}

_extract_docker_options() {
    local cmd="$1"
    local help_output
    help_output=$(docker "$cmd" --help 2>/dev/null || true)
    _completion_filter_options "$help_output" "--?"
}

_extract_docker_compose_options() {
    local cmd="$1"
    local help_output
    help_output=$(docker-compose "$cmd" --help 2>/dev/null || true)
    _completion_filter_options "$help_output" "--?"
}

# Register completions
complete -o default -o bashdefault -F _docker_complete docker
complete -o default -o bashdefault -F _docker_compose_complete docker-compose
