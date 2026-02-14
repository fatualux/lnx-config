#!/bin/bash

__bash_autopairs_insert_pair() {
    local open="$1"
    local close="$2"

    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${open}${close}${READLINE_LINE:READLINE_POINT}"
    ((READLINE_POINT+=1))
}

__bash_autopairs_close_or_skip() {
    local close="$1"

    if [[ "${READLINE_LINE:READLINE_POINT:1}" == "$close" ]]; then
        ((READLINE_POINT+=1))
        return 0
    fi

    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${close}${READLINE_LINE:READLINE_POINT}"
    ((READLINE_POINT+=1))
}

__bash_autopairs_quote_or_skip() {
    local q="$1"

    if [[ "${READLINE_LINE:READLINE_POINT:1}" == "$q" ]]; then
        ((READLINE_POINT+=1))
        return 0
    fi

    READLINE_LINE="${READLINE_LINE:0:READLINE_POINT}${q}${q}${READLINE_LINE:READLINE_POINT}"
    ((READLINE_POINT+=1))
}

__bash_autopairs_handle_paren_open() { __bash_autopairs_insert_pair "(" ")"; }
__bash_autopairs_handle_bracket_open() { __bash_autopairs_insert_pair "[" "]"; }
__bash_autopairs_handle_brace_open() { __bash_autopairs_insert_pair "{" "}"; }

__bash_autopairs_handle_paren_close() { __bash_autopairs_close_or_skip ")"; }
__bash_autopairs_handle_bracket_close() { __bash_autopairs_close_or_skip "]"; }
__bash_autopairs_handle_brace_close() { __bash_autopairs_close_or_skip "}"; }

__bash_autopairs_handle_double_quote() { __bash_autopairs_quote_or_skip '"'; }
__bash_autopairs_handle_single_quote() { __bash_autopairs_quote_or_skip "'"; }

__bash_autopairs_init() {
    if [[ $- != *i* ]]; then
        return 0
    fi

    local km
    for km in emacs-standard vi-insert; do
        bind -m "$km" -x '"(": __bash_autopairs_handle_paren_open'
        bind -m "$km" -x '")": __bash_autopairs_handle_paren_close'
        bind -m "$km" -x '"[": __bash_autopairs_handle_bracket_open'
        bind -m "$km" -x '"]": __bash_autopairs_handle_bracket_close'
        bind -m "$km" -x '"{": __bash_autopairs_handle_brace_open'
        bind -m "$km" -x '"}": __bash_autopairs_handle_brace_close'

        bind -m "$km" -x '"\"": __bash_autopairs_handle_double_quote'
        bind -m "$km" -x "\"'\": __bash_autopairs_handle_single_quote"
    done
}
