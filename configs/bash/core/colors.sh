#!/bin/bash

# Guard against re-sourcing to prevent readonly variable conflicts
[[ -n "$__COLORS_SOURCED" ]] && return 0

# Colors module - centralized color definitions for bash configuration
# Usage: source this file to access color variables

# Regular Colors
readonly COLOR_BLACK='\033[0;30m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[0;37m'

# Bold Colors
readonly COLOR_BOLD_BLACK='\033[1;30m'
readonly COLOR_BOLD_RED='\033[1;31m'
readonly COLOR_BOLD_GREEN='\033[1;32m'
readonly COLOR_BOLD_YELLOW='\033[1;33m'
readonly COLOR_BOLD_BLUE='\033[1;34m'
readonly COLOR_BOLD_MAGENTA='\033[1;35m'
readonly COLOR_BOLD_CYAN='\033[1;36m'
readonly COLOR_BOLD_WHITE='\033[1;37m'

# Underline Colors
readonly COLOR_UNDERLINE_BLACK='\033[4;30m'
readonly COLOR_UNDERLINE_RED='\033[4;31m'
readonly COLOR_UNDERLINE_GREEN='\033[4;32m'
readonly COLOR_UNDERLINE_YELLOW='\033[4;33m'
readonly COLOR_UNDERLINE_BLUE='\033[4;34m'
readonly COLOR_UNDERLINE_MAGENTA='\033[4;35m'
readonly COLOR_UNDERLINE_CYAN='\033[4;36m'
readonly COLOR_UNDERLINE_WHITE='\033[4;37m'

# Background Colors
readonly COLOR_BG_BLACK='\033[40m'
readonly COLOR_BG_RED='\033[41m'
readonly COLOR_BG_GREEN='\033[42m'
readonly COLOR_BG_YELLOW='\033[43m'
readonly COLOR_BG_BLUE='\033[44m'
readonly COLOR_BG_MAGENTA='\033[45m'
readonly COLOR_BG_CYAN='\033[46m'
readonly COLOR_BG_WHITE='\033[47m'

# High Intensity Colors
readonly COLOR_INTENSE_BLACK='\033[0;90m'
readonly COLOR_INTENSE_RED='\033[0;91m'
readonly COLOR_INTENSE_GREEN='\033[0;92m'
readonly COLOR_INTENSE_YELLOW='\033[0;93m'
readonly COLOR_INTENSE_BLUE='\033[0;94m'
readonly COLOR_INTENSE_MAGENTA='\033[0;95m'
readonly COLOR_INTENSE_CYAN='\033[0;96m'
readonly COLOR_INTENSE_WHITE='\033[0;97m'

# Bold High Intensity Colors
readonly COLOR_BOLD_INTENSE_BLACK='\033[1;90m'
readonly COLOR_BOLD_INTENSE_RED='\033[1;91m'
readonly COLOR_BOLD_INTENSE_GREEN='\033[1;92m'
readonly COLOR_BOLD_INTENSE_YELLOW='\033[1;93m'
readonly COLOR_BOLD_INTENSE_BLUE='\033[1;94m'
readonly COLOR_BOLD_INTENSE_MAGENTA='\033[1;95m'
readonly COLOR_BOLD_INTENSE_CYAN='\033[1;96m'
readonly COLOR_BOLD_INTENSE_WHITE='\033[1;97m'

# High Intensity Background Colors
readonly COLOR_BG_INTENSE_BLACK='\033[0;100m'
readonly COLOR_BG_INTENSE_RED='\033[0;101m'
readonly COLOR_BG_INTENSE_GREEN='\033[0;102m'
readonly COLOR_BG_INTENSE_YELLOW='\033[0;103m'
readonly COLOR_BG_INTENSE_BLUE='\033[0;104m'
readonly COLOR_BG_INTENSE_MAGENTA='\033[0;105m'
readonly COLOR_BG_INTENSE_CYAN='\033[0;106m'
readonly COLOR_BG_INTENSE_WHITE='\033[0;107m'

# Special formatting
readonly COLOR_RESET='\033[0m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_DIM='\033[2m'
readonly COLOR_ITALIC='\033[3m'
readonly COLOR_UNDERLINE='\033[4m'
readonly COLOR_BLINK='\033[5m'
readonly COLOR_REVERSE='\033[7m'
readonly COLOR_HIDDEN='\033[8m'
readonly COLOR_STRIKETHROUGH='\033[9m'

# Reset/No Color
readonly NC='\033[0m'

# Aliases for common usage (backward compatibility)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'

# Special characters (ASCII safe versions)
readonly CHAR_CHECKMARK='✓ '
readonly CHAR_CROSS='✗ '
readonly CHAR_WARNING='! '
readonly CHAR_INFO='🛈 '
readonly CHAR_ARROW='→ '
readonly CHAR_BULLET='• '
readonly CHAR_STAR='[*]'
readonly CHAR_SQUARE='[■] '

# Mark colors as sourced to prevent re-sourcing
readonly __COLORS_SOURCED=1
