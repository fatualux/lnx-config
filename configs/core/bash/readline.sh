#!/bin/bash
# Readline settings for more responsive completion behavior.

if [[ $- != *i* ]]; then
    return 0
fi

: "${BASH_CONFIG_READLINE_SHOW_ALL:=1}"
: "${BASH_CONFIG_READLINE_MENU_COMPLETE:=1}"
: "${BASH_CONFIG_READLINE_NO_QUERY:=1}"

if [[ ${BASH_CONFIG_READLINE_SHOW_ALL} == "1" ]]; then
    bind 'set show-all-if-ambiguous on'
fi

if [[ ${BASH_CONFIG_READLINE_NO_QUERY} == "1" ]]; then
    bind 'set completion-query-items 0'
fi

if [[ ${BASH_CONFIG_READLINE_MENU_COMPLETE} == "1" ]]; then
    bind 'set menu-complete-display-prefix on'
    bind 'TAB:menu-complete'
fi
