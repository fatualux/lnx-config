#!/bin/bash

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -d /nix/store ] && [ -f /etc/nixos-version ]; then
        echo "nixos"
    elif command -v nixos-version >/dev/null 2>&1; then
        echo "nixos"
    else
        echo "unknown"
    fi
}
