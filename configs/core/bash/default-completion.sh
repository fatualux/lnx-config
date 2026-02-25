#!/bin/bash

# Helper function to split string into array (replaces _omb_util_split)
_split_to_array() {
    local -n arr_ref=$1
    local str=$2
    local delimiter=$3
    IFS="$delimiter" read -ra arr_ref <<< "$str"
}

_defaults_domains() {
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    local domains
    domains=$(defaults domains | sed -e 's/, /:/g' | tr : '\n' | sed -e 's/ /\\ /g' | grep -i "^$cur")
    _split_to_array COMPREPLY "$domains" $'\n'
    if grep -q "^$cur" <<< '-app'; then
        COMPREPLY[${#COMPREPLY[@]}]="-app"
    fi
    return 0
}

_defaults() {
    local cur prev host_opts cmds cmd domain keys key_index
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    host_opts='-currentHost -host'
    cmds='read read-type write rename delete domains find help'

    if ((COMP_CWORD == 1)); then
        COMPREPLY=( $(compgen -W "$host_opts $cmds" -- "$cur") )
        return 0
    elif ((COMP_CWORD == 2)); then
        if [[ $prev == "-currentHost" ]]; then
            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
            return 0
        elif [[ $prev == "-host" ]]; then
            if declare -f _known_hosts >/dev/null; then
                _known_hosts -a
            fi
            return 0
        else
            _defaults_domains
            return 0
        fi
    elif ((COMP_CWORD == 3)); then
        if [[ ${COMP_WORDS[1]} == "-host" ]]; then
            _defaults_domains
            return 0
        fi
    fi

    # Both a domain and command have been specified

    if [[ ${COMP_WORDS[1]} == @(${cmds// /|}) ]]; then
        cmd=${COMP_WORDS[1]}
        domain=${COMP_WORDS[2]}
        key_index=3
        if [[ $domain == "-app" ]]; then
            if ((COMP_CWORD == 3)); then
                # Completing application name. Can't help here, sorry
                return 0
            fi
            domain="-app ${COMP_WORDS[3]}"
            key_index=4
        fi
    elif [[ ${COMP_WORDS[2]} == "-currentHost" && ${COMP_WORDS[2]} == @(${cmds// /|}) ]]; then
        cmd=${COMP_WORDS[2]}
        domain=${COMP_WORDS[3]}
        key_index=4
        if [[ "$domain" == "-app" ]]; then
            if [[ $COMP_CWORD -eq 4 ]]; then
                # Completing application name. Can't help here, sorry
                return 0
            fi
            domain="-app ${COMP_WORDS[4]}"
            key_index=5
        fi
    elif [[ ${COMP_WORDS[3]} == "-host" && ${COMP_WORDS[3]} == @(${cmds// /|}) ]]; then
        cmd=${COMP_WORDS[3]}
        domain=${COMP_WORDS[4]}
        key_index=5
        if [[ $domain == "-app" ]]; then
            if ((COMP_CWORD == 5)); then
                # Completing application name. Can't help here, sorry
                return 0
            fi
            domain="-app ${COMP_WORDS[5]}"
            key_index=6
        fi
    fi

    keys=$(defaults read $domain 2>/dev/null |
           sed -ne '/^    [^}) ]/p' |
           sed -e 's/^    \([^" ]\{1,\}\) = .*$/\1/g' -e 's/^    "\([^"]\{1,\}\)" = .*$/\1/g' |
           sed -e 's/ /\\ /g' )

    case $cmd in
    read|read-type)
        # Complete key
        local IFS=$'\n'
        COMPREPLY=( $(grep -i "^${cur//\\/\\\\}" <<< "$keys") )
        ;;
    write)
        if ((key_index == COMP_CWORD)); then
            # Complete key
            local IFS=$'\n'
            COMPREPLY=( $(grep -i "^${cur//\\/\\\\}" <<< "$keys") )
        elif ((key_index + 1 == COMP_CWORD)); then
            # Complete value type
            # Unfortunately ${COMP_WORDS[key_index]} fails on keys with spaces
            local value_types='-string -data -integer -float -boolean -date -array -array-add -dict -dict-add'
            local cur_type
            cur_type=$(defaults read-type $domain ${COMP_WORDS[key_index]} 2>/dev/null | sed -e 's/^Type is \(.*\)/-\1/' -e's/dictionary/dict/' | grep "^$cur")
            if [[ $cur_type ]]; then
                COMPREPLY=( $cur_type )
            else
                COMPREPLY=( $(compgen -W "$value_types" -- "$cur") )
            fi
        elif ((key_index + 2 == COMP_CWORD)); then
            # Complete value
            # Unfortunately ${COMP_WORDS[key_index]} fails on keys with spaces
            COMPREPLY=( $(defaults read $domain ${COMP_WORDS[key_index]} 2>/dev/null | grep -i "^${cur//\\/\\\\}") )
        fi
        ;;
    rename)
        if ((key_index == COMP_CWORD || key_index + 1 == COMP_CWORD)); then
            # Complete source and destination keys
            local IFS=$'\n'
            COMPREPLY=( $(grep -i "^${cur//\\/\\\\}" <<< "$keys") )
        fi
        ;;
    delete)
        if ((key_index == COMP_CWORD)); then
            # Complete key
            local IFS=$'\n'
            COMPREPLY=( $(grep -i "^${cur//\\/\\\\}" <<< "$keys") )
        fi
        ;;
    esac

    return 0
}

complete -F _defaults -o default defaults
