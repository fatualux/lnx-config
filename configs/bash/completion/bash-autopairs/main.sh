#!/bin/bash

if [[ $- != *i* ]]; then
    return 0
fi

if [[ -n "${__BASH_AUTOPAIRS_LOADED:-}" ]]; then
    return 0
fi
__BASH_AUTOPAIRS_LOADED=1

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/autopairs.sh"

__bash_autopairs_init
