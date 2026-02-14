#!/bin/bash
# ============================================================================
# Docker Bash Completion
# ============================================================================
# Comprehensive completion with Docker CLI and Docker Compose integration
# Based on Docker CLI and Docker Compose v1 completion scripts
# Features:
#   - Complete container/image/network/volume/service completion
#   - Smart caching (5-minute TTL)
#   - Driver-specific options
#   - Docker Compose integration
# ============================================================================

# shellcheck disable=SC2016,SC2119,SC2155,SC2206,SC2207,SC2254

if [[ -z "$_DOCKER_COMPLETION_ENHANCED_LOADED" ]]; then
    _DOCKER_COMPLETION_ENHANCED_LOADED=1

    # Cache directory for Docker completions
    _DOCKER_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/docker-complete"
    _DOCKER_CACHE_TTL=300  # 5 minutes cache for dynamic data

    # Create cache directory with error handling
    if ! mkdir -p "$_DOCKER_CACHE_DIR" 2>/dev/null; then
        # Fallback to temporary directory if cache directory can't be created
        _DOCKER_CACHE_DIR="${TMPDIR:-/tmp}/docker-complete-$$"
        mkdir -p "$_DOCKER_CACHE_DIR" 2>/dev/null || true
    fi

    # ============================================================================
    # Utility Functions (from Docker CLI completion)
    # ============================================================================

    __docker_previous_extglob_setting=$(shopt -p extglob)
    shopt -s extglob

    # Query Docker with optional host/config/context
    __docker_q() {
        if ! __docker_command_exists docker; then
            return 1
        fi
        docker ${host:+--host "$host"} ${config:+--config "$config"} ${context:+--context "$context"} 2>/dev/null "$@"
    }

    # Transform multiline list to alternatives
    __docker_to_alternatives() {
        local parts=( $1 )
        local IFS='|'
        echo "${parts[*]}"
    }

    # Transform multiline list to extglob pattern
    __docker_to_extglob() {
        local extglob=$( __docker_to_alternatives "$1" )
        echo "@($extglob)"
    }

    # Check if option exists on command line
    __docker_has_option() {
        local pattern="$1"
        for (( i=2; i < $cword; ++i)); do
            if [[ ${words[$i]} =~ ^($pattern)$ ]] ; then
                return 0
            fi
        done
        return 1
    }

    # Get key of current map option
    __docker_map_key_of_current_option() {
        local glob="$1"
        local cur="$2"
        local prev="$3"
        local cword="$4"
        local -a words=("${@:5}")
        local key glob_pos
        if [ "$cur" = "=" ] ; then
            key="$prev"
            glob_pos=$((cword - 2))
        elif [[ $cur == *=* ]] ; then
            key=${cur%=*}
            glob_pos=$((cword - 1))
        elif [ "$prev" = "=" ] ; then
            key=${words[$cword - 2]}
            glob_pos=$((cword - 3))
        else
            return
        fi
        [ "${words[$glob_pos]}" = "=" ] && ((glob_pos--))
        [[ ${words[$glob_pos]} == @($glob) ]] && echo "$key"
    }

    # Utility function to check if command exists
    __docker_command_exists() {
        command -v "$1" >/dev/null 2>&1
    }

    # Suppress trailing whitespace
    __docker_nospace() {
        __docker_command_exists compopt && compopt -o nospace
    }

    # Trim colon completions (basic implementation)
    __ltrim_colon_completions() {
        local cur="$1"
        # Basic implementation - can be enhanced if needed
        return
    }

    # Get position of first non-flag
    __docker_pos_first_nonflag() {
        local argument_flags=${1-}
        local counter=$((${subcommand_pos:-${command_pos}} + 1))
        while [ "$counter" -le "$cword" ]; do
            if [ -n "$argument_flags" ] && eval "case '${words[$counter]}' in $argument_flags) true ;; *) false ;; esac"; then
                (( counter++ ))
                [ "${words[$counter]}" = "=" ] && (( counter++ ))
            else
                case "${words[$counter]}" in
                    -*)
                        ;;
                    *)
                        break
                        ;;
                esac
            fi
            while [ "${words[$counter + 1]}" = "=" ] ; do
                counter=$(( counter + 2))
            done
            (( counter++ ))
        done
        echo "$counter"
    }

    # ============================================================================
    # Docker Resource Functions
    # ============================================================================

    # Get containers with format options
    __docker_containers() {
        local format='{{.Names}}'
        if [ "${DOCKER_COMPLETION_SHOW_CONTAINER_IDS-}" = yes ] ; then
            format='{{.ID}} {{.Names}}'
        fi
        if [ "${1-}" = "--id" ] ; then
            format='{{.ID}}'
            shift
        elif [ "${1-}" = "--name" ] ; then
            format='{{.Names}}'
            shift
        fi
        __docker_q ps --format "$format" "$@"
    }

    # Get images with format options
    __docker_images() {
        local repo_format='{{.Repository}}'
        local tag_format='{{.Repository}}:{{.Tag}}'
        local id_format='{{.ID}}'
        local all
        local format

        if [ "${DOCKER_COMPLETION_SHOW_IMAGE_IDS-}" = "all" ] ; then
            all='--all'
        fi

        while true ; do
            case "${1-}" in
                --repo)
                    format+="$repo_format\n"
                    shift
                    ;;
                --tag)
                    if [ "${DOCKER_COMPLETION_SHOW_TAGS:-yes}" = "yes" ]; then
                        format+="$tag_format\n"
                    fi
                    shift
                    ;;
                --id)
                    if [[ ${DOCKER_COMPLETION_SHOW_IMAGE_IDS-} =~ ^(all|non-intermediate)$ ]] ; then
                        format+="$id_format\n"
                    fi
                    shift
                    ;;
                --force-tag)
                    format+="$tag_format\n"
                    shift
                    ;;
                *)
                    break
                    ;;
            esac
        done

        __docker_q image ls --no-trunc --format "${format%\\n}" ${all-} "$@" | grep -v '<none>$'
    }

    # Get networks
    __docker_networks() {
        local format='{{.Name}}'
        if [ "${DOCKER_COMPLETION_SHOW_NETWORK_IDS-}" = yes ] ; then
            format='{{.ID}} {{.Name}}'
        fi
        if [ "${1-}" = "--id" ] ; then
            format='{{.ID}}'
            shift
        elif [ "${1-}" = "--name" ] ; then
            format='{{.Name}}'
            shift
        fi
        __docker_q network ls --format "$format" "$@"
    }

    # Get volumes
    __docker_volumes() {
        __docker_q volume ls -q "$@"
    }

    # Get services
    __docker_services() {
        local format='{{.Name}}'
        [ "${DOCKER_COMPLETION_SHOW_SERVICE_IDS-}" = yes ] && format='{{.ID}} {{.Name}}'
        if [ "${1-}" = "--id" ] ; then
            format='{{.ID}}'
            shift
        elif [ "${1-}" = "--name" ] ; then
            format='{{.Name}}'
            shift
        fi
        __docker_q service ls --quiet --format "$format" "$@"
    }

    # ============================================================================
    # Docker Compose Functions
    # ============================================================================

    __docker_compose_previous_extglob_setting=$(shopt -p extglob)
    shopt -s extglob

    __docker_compose_q() {
        if ! __docker_command_exists docker-compose && ! __docker_command_exists compose; then
            return 1
        fi
        # Try docker-compose first, then compose (Docker Compose v2)
        if __docker_command_exists docker-compose; then
            docker-compose 2>/dev/null "${top_level_options[@]}" "$@"
        else
            compose 2>/dev/null "${top_level_options[@]}" "$@"
        fi
    }

    # Transform multiline list to alternatives (Docker Compose version)
    __docker_compose_to_alternatives() {
        local parts=( $1 )
        local IFS='|'
        echo "${parts[*]}"
    }

    # Transform multiline list to extglob pattern (Docker Compose version)
    __docker_compose_to_extglob() {
        local extglob=$( __docker_compose_to_alternatives "$1" )
        echo "@($extglob)"
    }

    # Get Docker Compose services
    __docker_compose_services() {
        __docker_compose_q ps --services "$@"
    }

    # Apply completion of Docker Compose services
    __docker_compose_complete_services() {
        COMPREPLY=( $(compgen -W "$(__docker_compose_services "$@")" -- "$cur") )
    }

    # ============================================================================
    # Cached Resource Functions (Enhanced with Docker CLI patterns)
    # ============================================================================

    # Get all containers (cached)
    _docker_get_all_containers() {
        local cache="$_DOCKER_CACHE_DIR/all_containers"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local containers
        containers=$(__docker_containers --all)
        echo "$containers" | tee "$cache" 2>/dev/null
    }

    # Get running containers only (cached)
    _docker_get_running_containers() {
        local cache="$_DOCKER_CACHE_DIR/running_containers"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local containers
        containers=$(__docker_containers)
        echo "$containers" | tee "$cache" 2>/dev/null
    }

    # Get all images (cached)
    _docker_get_all_images() {
        local cache="$_DOCKER_CACHE_DIR/all_images"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local images
        images=$(__docker_images --repo --tag)
        echo "$images" | tee "$cache" 2>/dev/null
    }

    # Get volumes (cached)
    _docker_get_volumes() {
        local cache="$_DOCKER_CACHE_DIR/volumes"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local volumes
        volumes=$(__docker_volumes)
        echo "$volumes" | tee "$cache" 2>/dev/null
    }

    # Get networks (cached)
    _docker_get_networks() {
        local cache="$_DOCKER_CACHE_DIR/networks"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local networks
        networks=$(__docker_networks)
        echo "$networks" | tee "$cache" 2>/dev/null
    }

    # Get services (cached)
    _docker_get_services() {
        local cache="$_DOCKER_CACHE_DIR/services"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local services
        services=$(__docker_services)
        echo "$services" | tee "$cache" 2>/dev/null
    }

    # Get Docker Compose services (cached)
    _docker_compose_get_services() {
        local cache="$_DOCKER_CACHE_DIR/compose_services"
        if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt $_DOCKER_CACHE_TTL ]]; then
            cat "$cache" 2>/dev/null
            return
        fi
        
        local services
        services=$(docker-compose config --services 2>/dev/null || docker compose config --services 2>/dev/null)
        echo "$services" | tee "$cache" 2>/dev/null
    }

    # ============================================================================
    # Enhanced Completion Functions
    # ============================================================================

    # Complete containers with proper filtering
    __docker_complete_containers() {
        local current="$cur"
        if [ "${1-}" = "--cur" ] ; then
            current="$2"
            shift 2
        fi
        COMPREPLY=( $(compgen -W "$(__docker_containers "$@")" -- "$current") )
    }

    # Complete images with proper filtering
    __docker_complete_images() {
        local current="$cur"
        if [ "${1-}" = "--cur" ] ; then
            current="$2"
            shift 2
        fi
        COMPREPLY=( $(compgen -W "$(__docker_images "$@")" -- "$current") )
        __ltrim_colon_completions "$current"
    }

    # Complete networks with proper filtering
    __docker_complete_networks() {
        local current="$cur"
        if [ "${1-}" = "--cur" ] ; then
            current="$2"
            shift 2
        fi
        COMPREPLY=( $(compgen -W "$(__docker_networks "$@")" -- "$current") )
    }

    # Complete volumes with proper filtering
    __docker_complete_volumes() {
        local current="$cur"
        if [ "${1-}" = "--cur" ] ; then
            current="$2"
            shift 2
        fi
        COMPREPLY=( $(compgen -W "$(__docker_volumes "$@")" -- "$current") )
    }

    # Complete services with proper filtering
    __docker_complete_services() {
        local current="$cur"
        if [ "${1-}" = "--cur" ] ; then
            current="$2"
            shift 2
        fi
        COMPREPLY=( $(__docker_services "$@" --filter "name=$current") )
    }

    # Complete capabilities (addable)
    __docker_complete_capabilities_addable() {
        local capabilities=(
            ALL
            CAP_AUDIT_CONTROL
            CAP_AUDIT_READ
            CAP_BLOCK_SUSPEND
            CAP_BPF
            CAP_CHECKPOINT_RESTORE
            CAP_DAC_READ_SEARCH
            CAP_IPC_LOCK
            CAP_IPC_OWNER
            CAP_LEASE
            CAP_LINUX_IMMUTABLE
            CAP_MAC_ADMIN
            CAP_MAC_OVERRIDE
            CAP_NET_ADMIN
            CAP_NET_BROADCAST
            CAP_PERFMON
            CAP_SYS_ADMIN
            CAP_SYS_BOOT
            CAP_SYSLOG
            CAP_SYS_MODULE
            CAP_SYS_NICE
            CAP_SYS_PACCT
            CAP_SYS_PTRACE
            CAP_SYS_RAWIO
            CAP_SYS_RESOURCE
            CAP_SYS_TIME
            CAP_SYS_TTY_CONFIG
            CAP_WAKE_ALARM
            RESET
        )
        COMPREPLY=( $( compgen -W "${capabilities[*]} ${capabilities[*]#CAP_}" -- "$cur" ) )
    }

    # Complete capabilities (droppable)
    __docker_complete_capabilities_droppable() {
        local capabilities=(
            ALL
            CAP_AUDIT_WRITE
            CAP_CHOWN
            CAP_DAC_OVERRIDE
            CAP_FOWNER
            CAP_FSETID
            CAP_KILL
            CAP_MKNOD
            CAP_NET_BIND_SERVICE
            CAP_NET_RAW
            CAP_SETFCAP
            CAP_SETGID
            CAP_SETPCAP
            CAP_SETUID
            CAP_SYS_CHROOT
            RESET
        )
        COMPREPLY=( $( compgen -W "${capabilities[*]} ${capabilities[*]#CAP_}" -- "$cur" ) )
    }

    # Complete log drivers
    __docker_complete_log_drivers() {
        COMPREPLY=( $( compgen -W "
            awslogs
            etwlogs
            fluentd
            gcplogs
            gelf
            journald
            json-file
            local
            none
            splunk
            syslog
        " -- "$cur" ) )
    }

    # Complete signals
    __docker_complete_signals() {
        local signals=(
            SIGCONT
            SIGHUP
            SIGINT
            SIGKILL
            SIGQUIT
            SIGSTOP
            SIGTERM
            SIGUSR1
            SIGUSR2
        )
        COMPREPLY=( $( compgen -W "${signals[*]} ${signals[*]#SIG}" -- "$cur" ) )
    }

    # ============================================================================
    # Docker Compose Command Completions
    # ============================================================================

    _docker_compose_build() {
        case "$prev" in
            --build-arg)
                COMPREPLY=( $( compgen -e -- "$cur" ) )
                __docker_nospace
                return
                ;;
            --memory|-m)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--build-arg --compress --force-rm --help --memory -m --no-cache --no-rm --pull --parallel -q --quiet" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter source=build
                ;;
        esac
    }

    _docker_compose_config() {
        case "$prev" in
            --hash)
                if [[ $cur == \\* ]] ; then
                    COMPREPLY=( '\*' )
                else
                    COMPREPLY=( $(compgen -W "$(__docker_compose_services) \\* " -- "$cur") )
                fi
                return
                ;;
        esac

        COMPREPLY=( $( compgen -W "--hash --help --no-interpolate --profiles --quiet -q --resolve-image-digests --services --volumes" -- "$cur" ) )
    }

    _docker_compose_up() {
        case "$prev" in
            =)
                COMPREPLY=("$cur")
                return
                ;;
            --exit-code-from)
                __docker_compose_complete_services
                return
                ;;
            --scale)
                COMPREPLY=( $(compgen -S "=" -W "$(__docker_compose_services)" -- "$cur") )
                __docker_nospace
                return
                ;;
            --timeout|-t)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--abort-on-container-exit --always-recreate-deps --attach-dependencies --build -d --detach --exit-code-from --force-recreate --help --no-build --no-color --no-deps --no-log-prefix --no-recreate --no-start --renew-anon-volumes -V --remove-orphans --scale --timeout -t" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services
                ;;
        esac
    }

    _docker_compose_down() {
        case "$prev" in
            --rmi)
                COMPREPLY=( $( compgen -W "all local" -- "$cur" ) )
                return
                ;;
            --timeout|-t)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--help --rmi --timeout -t --volumes -v --remove-orphans" -- "$cur" ) )
                ;;
        esac
    }

    _docker_compose_ps() {
        local key=$(__docker_map_key_of_current_option '--filter' "$cur" "$prev" "$cword" "${words[@]}")
        case "$key" in
            source)
                COMPREPLY=( $( compgen -W "build image" -- "${cur##*=}" ) )
                return
                ;;
            status)
                COMPREPLY=( $( compgen -W "paused restarting running stopped" -- "${cur##*=}" ) )
                return
                ;;
        esac

        case "$prev" in
            --filter)
                COMPREPLY=( $( compgen -W "source status" -S "=" -- "$cur" ) )
                __docker_nospace
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--all -a --filter --help --quiet -q --services" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services
                ;;
        esac
    }

    _docker_compose_exec() {
        case "$prev" in
            --index|--user|-u|--workdir|-w)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "-d --detach --help --index --privileged -T --user -u --workdir -w" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter status=running
                ;;
        esac
    }

    _docker_compose_logs() {
        case "$prev" in
            --tail)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--follow -f --help --no-color --no-log-prefix --tail --timestamps -t" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services
                ;;
        esac
    }

    _docker_compose_restart() {
        case "$prev" in
            --timeout|-t)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--help --timeout -t" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter status=running
                ;;
        esac
    }

    _docker_compose_stop() {
        case "$prev" in
            --timeout|-t)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--help --timeout -t" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter status=running
                ;;
        esac
    }

    _docker_compose_rm() {
        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--force -f --help --stop -s -v" -- "$cur" ) )
                ;;
            *)
                if __docker_has_option "--stop|-s" ; then
                    __docker_compose_complete_services
                else
                    __docker_compose_complete_services --filter status=stopped
                fi
                ;;
        esac
    }

    _docker_compose_kill() {
        case "$prev" in
            -s)
                COMPREPLY=( $( compgen -W "SIGHUP SIGINT SIGKILL SIGUSR1 SIGUSR2" -- "$(echo $cur | tr '[:lower:]' '[:upper:]')" ) )
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--help -s" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter status=running
                ;;
        esac
    }

    _docker_compose_run() {
        case "$prev" in
            -e)
                COMPREPLY=( $( compgen -e -- "$cur" ) )
                __docker_nospace
                return
                ;;
            --entrypoint|--label|-l|--name|--user|-u|--volume|-v|--workdir|-w)
                return
                ;;
        esac

        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--detach -d --entrypoint -e --help --label -l --name --no-deps --publish -p --rm --service-ports -T --use-aliases --user -u --volume -v --workdir -w" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services
                ;;
        esac
    }

    _docker_compose_pull() {
        case "$cur" in
            -*)
                COMPREPLY=( $( compgen -W "--help --ignore-pull-failures --include-deps --no-parallel --quiet -q" -- "$cur" ) )
                ;;
            *)
                __docker_compose_complete_services --filter source=image
                ;;
        esac
    }

    # Main Docker Compose completion function
    _docker_compose() {
        local previous_extglob_setting=$(shopt -p extglob)
        shopt -s extglob

        local commands=(
            build
            config
            create
            down
            events
            exec
            help
            images
            kill
            logs
            pause
            port
            ps
            pull
            push
            restart
            rm
            run
            scale
            start
            stop
            top
            unpause
            up
            version
        )

        local daemon_boolean_options="
            --skip-hostname-check
            --tls
            --tlsverify
        "
        local daemon_options_with_args="
            --context -c
            --env-file
            --file -f
            --host -H
            --project-directory
            --project-name -p
            --tlscacert
            --tlscert
            --tlskey
        "

        local top_level_options_with_args="
            --ansi
            --log-level
            --profile
        "

        COMPREPLY=()
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        local words=("${COMP_WORDS[@]}")
        local cword=$COMP_CWORD

        local command='docker_compose'
        local top_level_options=()
        local counter=1

        while [ $counter -lt $cword ]; do
            case "${words[$counter]}" in
                $(__docker_compose_to_extglob "$daemon_boolean_options") )
                    local opt=${words[counter]}
                    top_level_options+=($opt)
                    ;;
                $(__docker_compose_to_extglob "$daemon_options_with_args") )
                    local opt=${words[counter]}
                    local arg=${words[++counter]}
                    top_level_options+=($opt $arg)
                    ;;
                $(__docker_compose_to_extglob "$top_level_options_with_args") )
                    (( counter++ ))
                    ;;
                    -*)
                    ;;
                    *)
                    command="${words[$counter]}"
                    break
                    ;;
            esac
            (( counter++ ))
        done

        local completions_func=_docker_compose_${command//-/_}
        _omb_util_function_exists "$completions_func" && "$completions_func"

        eval "$previous_extglob_setting"
        return 0
    }

    # ============================================================================
    # Main Docker Completion Functions (Enhanced)
    # ============================================================================

    _docker_all_containers_completion() {
        local cur="$1"
        local containers=$(_docker_get_all_containers)
        COMPREPLY=($(compgen -W "$containers" -- "$cur"))
    }

    _docker_containers_completion() {
        local cur="$1"
        local containers=$(_docker_get_running_containers)
        COMPREPLY=($(compgen -W "$containers" -- "$cur"))
    }

    _docker_all_images_completion() {
        local cur="$1"
        local images=$(_docker_get_all_images)
        COMPREPLY=($(compgen -W "$images" -- "$cur"))
    }

    # Enhanced Docker CLI completion with comprehensive command support
    _docker_complete() {
        if [[ -z "${COMP_CWORD+x}" || ${COMP_CWORD:-0} -lt 0 || ${#COMP_WORDS[@]} -eq 0 || ${COMP_CWORD:-0} -ge ${#COMP_WORDS[@]} ]]; then
            COMPREPLY=()
            return 0
        fi
        
        # Initialize completion variables properly
        COMPREPLY=()
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        local words=("${COMP_WORDS[@]}")
        local cword=$COMP_CWORD
        local cmd="${COMP_WORDS[1]:-}"
        local subcmd="${COMP_WORDS[2]:-}"

        local management_commands=(
            builder
            config
            container
            context
            image
            manifest
            network
            node
            plugin
            secret
            service
            stack
            swarm
            system
            trust
            volume
        )

        local top_level_commands=(
            build
            login
            logout
            run
            search
            version
        )

        local legacy_commands=(
            attach
            commit
            cp
            create
            diff
            events
            exec
            export
            history
            images
            import
            info
            inspect
            kill
            load
            logs
            pause
            port
            ps
            pull
            push
            rename
            restart
            rm
            rmi
            save
            start
            stats
            stop
            tag
            top
            unpause
            update
            wait
        )

        local commands=(${management_commands[*]} ${top_level_commands[*]})
        [ -z "${DOCKER_HIDE_LEGACY_COMMANDS-}" ] && commands+=(${legacy_commands[*]})

        # Global options
        local global_boolean_options="
            --debug -D
            --tls
            --tlsverify
        "
        local global_options_with_args="
            --config
            --context -c
            --host -H
            --log-level -l
            --tlscacert
            --tlscert
            --tlskey
        "

        local host config context
        local command='docker' command_pos=0 subcommand_pos
        local counter=1
        while [ "$counter" -lt "$cword" ]; do
            case "${words[$counter]}" in
                docker)
                    return 0
                    ;;
                --host|-H)
                    (( counter++ ))
                    host="${words[$counter]}"
                    ;;
                --config)
                    (( counter++ ))
                    config="${words[$counter]}"
                    ;;
                --context|-c)
                    (( counter++ ))
                    context="${words[$counter]}"
                    ;;
                $(__docker_to_extglob "$global_options_with_args") )
                    (( counter++ ))
                    ;;
                -*)
                    ;;
                =)
                    (( counter++ ))
                    ;;
                *)
                    command="${words[$counter]}"
                    command_pos=$counter
                    break
                    ;;
            esac
            (( counter++ ))
        done

        # Handle specific command completions
        case "$command" in
            # Container commands
            attach|exec|logs|pause|top|unpause|wait)
                __docker_complete_containers --filter status=running
                ;;
            start|restart|rm|stop|kill|diff|inspect|port|stats|update)
                __docker_complete_containers --all
                ;;
            # Image commands
            build|create|run|images|search|pull|push|rmi|tag|history|import|save|load)
                __docker_complete_images --repo --tag
                ;;
            # Network commands
            network)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "connect create disconnect inspect ls prune rm" -- "$cur" ) )
                else
                    case "${words[2]}" in
                        connect|disconnect|inspect|rm)
                            __docker_complete_networks
                            ;;
                        create)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--attachable --aux-address --config-from --config-only --driver -d --gateway --help --ingress --internal --ip-range --ipam-driver --ipam-opt --ipv6 --label --opt -o --scope --subnet" -- "$cur" ) )
                            fi
                            ;;
                        ls|prune)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--filter -f --format --help --no-trunc --quiet -q" -- "$cur" ) )
                            fi
                            ;;
                    esac
                fi
                ;;
            # Volume commands
            volume)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "create inspect ls prune rm" -- "$cur" ) )
                else
                    case "${words[2]}" in
                        inspect|rm)
                            __docker_complete_volumes
                            ;;
                        create)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--driver -d --help --label --opt -o" -- "$cur" ) )
                            fi
                            ;;
                        ls|prune)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--filter -f --format --help --quiet -q" -- "$cur" ) )
                            fi
                            ;;
                    esac
                fi
                ;;
            # Service commands (Swarm)
            service)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "create inspect logs ls ps rm rollback scale update" -- "$cur" ) )
                else
                    case "${words[2]}" in
                        inspect|logs|ps|rm|scale|update)
                            __docker_complete_services
                            ;;
                        create|update)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--detach -d --help --init --read-only --tty -t --with-registry-auth" -- "$cur" ) )
                            elif [[ "$prev" == "--cap-add" ]]; then
                                __docker_complete_capabilities_addable
                            elif [[ "$prev" == "--cap-drop" ]]; then
                                __docker_complete_capabilities_droppable
                            elif [[ "$prev" == "--log-driver" ]]; then
                                __docker_complete_log_drivers
                            elif [[ "$prev" == "--stop-signal" ]]; then
                                __docker_complete_signals
                            else
                                __docker_complete_images --repo --tag
                            fi
                            ;;
                        ls)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--filter -f --format --help --quiet -q" -- "$cur" ) )
                            fi
                            ;;
                    esac
                fi
                ;;
            # System commands
            system)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "df events info prune" -- "$cur" ) )
                else
                    case "${words[2]}" in
                        prune)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--all -a --force -f --filter --help --volumes" -- "$cur" ) )
                            fi
                            ;;
                        df|events|info)
                            if [[ "$cur" == -* ]]; then
                                COMPREPLY=( $( compgen -W "--format --help" -- "$cur" ) )
                            fi
                            ;;
                    esac
                fi
                ;;
            # Swarm commands
            swarm)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "ca init join join-token leave unlock unlock-key update" -- "$cur" ) )
                fi
                ;;
            # Plugin commands
            plugin)
                if [[ "$cword" -eq 2 ]]; then
                    COMPREPLY=( $( compgen -W "create disable enable inspect install ls push rm set upgrade" -- "$cur" ) )
                fi
                ;;
            # Default case - main docker command
            *)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=( $( compgen -W "$global_boolean_options $global_options_with_args --help -h --version -v" -- "$cur" ) )
                else
                    COMPREPLY=( $( compgen -W "${commands[*]}" -- "$cur" ) )
                fi
                ;;
        esac
    }

    # ============================================================================
    # Registration and Cleanup
    # ============================================================================

    # Register completions
    complete -F _docker_complete docker docker.exe dockerd dockerd.exe
    complete -F _docker_compose docker-compose docker-compose.exe compose
    
    # Cleanup extglob settings
    eval "$__docker_previous_extglob_setting"
    unset __docker_previous_extglob_setting
    eval "$__docker_compose_previous_extglob_setting"
    unset __docker_compose_previous_extglob_setting

fi
