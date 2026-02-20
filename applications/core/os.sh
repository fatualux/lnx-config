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

# Detect available package managers
detect_package_managers() {
    local managers=()
    
    # Check for common package managers in order of preference
    if command -v apt-get >/dev/null 2>&1; then
        managers+=("apt")
    fi
    if command -v dnf >/dev/null 2>&1; then
        managers+=("dnf")
    fi
    if command -v yum >/dev/null 2>&1; then
        managers+=("yum")
    fi
    if command -v pacman >/dev/null 2>&1; then
        managers+=("pacman")
    fi
    if command -v pkg >/dev/null 2>&1; then
        managers+=("pkg")
    fi
    if command -v apk >/dev/null 2>&1; then
        managers+=("apk")
    fi
    if command -v zypper >/dev/null 2>&1; then
        managers+=("zypper")
    fi
    
    echo "${managers[@]}"
}

# Map package manager to OS name for compatibility
map_pm_to_os() {
    local pm="$1"
    case "$pm" in
        apt)
            echo "debian"
            ;;
        dnf|yum)
            echo "fedora"
            ;;
        pacman)
            echo "arch"
            ;;
        pkg)
            echo "freebsd"
            ;;
        apk)
            echo "alpine"
            ;;
        zypper)
            echo "opensuse"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}
