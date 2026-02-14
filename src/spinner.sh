#!/bin/bash

# Spinner module for visual feedback during operations
# Provides light green spinner with various animation styles
[[ -z "$COLOR_GREEN" ]] && source "$(dirname "${BASH_SOURCE[0]}")/colors.sh" 2>/dev/null || true

# Spinner frame definitions
declare -x FRAME
declare -x FRAME_INTERVAL

# Configure spinner style
set_spinner() {
	case $1 in
		spinner1|default)
			# Larger dots with smooth animation - more visible
			FRAME=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
			FRAME_INTERVAL=0.08
			;;
		spinner2)
			# Classic with larger chars
			FRAME=("—" "\\" "|" "/")
			FRAME_INTERVAL=0.2
			;;
		spinner3)
			# Growing circle - pulsing effect
			FRAME=("◐" "◓" "◑" "◒")
			FRAME_INTERVAL=0.15
			;;
		spinner4)
			# Diamond pulse
			FRAME=("◇" "◈" "◆" "◈")
			FRAME_INTERVAL=0.2
			;;
		spinner5)
			# Elegant circles
			FRAME=("○" "◔" "◑" "◕" "●" "◕" "◑" "◔")
			FRAME_INTERVAL=0.1
			;;
		spinner6)
			# Progress blocks
			FRAME=("▱" "▰" "▰▱" "▰▰" "▰▰▱" "▰▰▰")
			FRAME_INTERVAL=0.15
			;;
		spinner7)
			# Bright dots
			FRAME=("∙∙∙" "●∙∙" "∙●∙" "∙∙●")
			FRAME_INTERVAL=0.2
			;;
		spinner8)
			# Arrow rotation
			FRAME=("←" "↖" "↑" "↗" "→" "↘" "↓" "↙")
			FRAME_INTERVAL=0.1
			;;
		dots)
			# Bold dots (same as default now)
			FRAME=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
			FRAME_INTERVAL=0.08
			;;
		*)
			# Default to bold dots
			FRAME=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
			FRAME_INTERVAL=0.08
			;;
	esac
}

# Start a spinner for an ongoing process
# Usage: spinner_start "message" [style]
spinner_start() {
	local message="${1:-Working}"
	local style="${2:-default}"
	# Ensure any previous spinner is cleaned up before starting a new one
	spinner_cleanup
	SPINNER_PID_FILE="$(mktemp)"
	local CLEAR_LINE="\033[K"
	
	# Set spinner style
	set_spinner "$style"
	
	# Export frames for subshell access
	local frames=("${FRAME[@]}")
	local interval="$FRAME_INTERVAL"
	
	# Hide cursor
	tput civis 2>/dev/null || true
	
	# Background spinner process
	(
		while [[ -f "$SPINNER_PID_FILE" ]]; do
			for frame in "${frames[@]}"; do
				[[ ! -f "$SPINNER_PID_FILE" ]] && break
				# Bold bright green for better visibility
				printf "\r${COLOR_BOLD_GREEN}${frame}${NC}  ${message}${CLEAR_LINE}"
				sleep "$interval"
			done
		done
		# Clear the line when done
		printf "\r${CLEAR_LINE}"
	) &
	
	local spinner_pid=$!
	echo "$spinner_pid" > "$SPINNER_PID_FILE"
	
	export SPINNER_PID_FILE
}

# Stop the spinner and show completion status
# Usage: spinner_stop [success_message] [error_message]
spinner_stop() {
	local success_msg="${1:-}"
	local error_msg="${2:-}"
	local exit_code="${3:-0}"
	local CLEAR_LINE="\033[K"
	
	if [[ -n "${SPINNER_PID_FILE:-}" && -f "$SPINNER_PID_FILE" ]]; then
		local spinner_pid
		spinner_pid=$(<"$SPINNER_PID_FILE")
		
		rm -f "$SPINNER_PID_FILE"
		kill "$spinner_pid" 2>/dev/null || true
		wait "$spinner_pid" 2>/dev/null || true
		
		unset SPINNER_PID_FILE
	fi
	
	# Show cursor
	tput cnorm 2>/dev/null || true
	
	# Print completion message
	if [[ $exit_code -eq 0 ]]; then
		if [[ -n "$success_msg" ]]; then
			printf "\r${COLOR_BOLD_GREEN}✔${NC}  ${success_msg}${CLEAR_LINE}\n"
		fi
	else
		if [[ -n "$error_msg" ]]; then
			printf "\r${COLOR_BOLD_RED}✗${NC}  ${error_msg}${CLEAR_LINE}\n"
		fi
	fi
}

# Execute a command with spinner
# Usage: spinner_exec "message" command [args...]
spinner_exec() {
	local message="$1"
	shift
	local cmd=("$@")
	
	spinner_start "$message"
	
	# Execute command
	local exit_code=0
	"${cmd[@]}" &>/dev/null || exit_code=$?
	
	if [[ $exit_code -eq 0 ]]; then
		spinner_stop "$message - Complete" "" 0
	else
		spinner_stop "" "$message - Failed" 1
	fi
	
	return $exit_code
}

# Multi-step spinner with task completion tracking
# Usage: 
#   spinner_multi_start
#   spinner_task "Task 1" command1
#   spinner_task "Task 2" command2
#   spinner_multi_finish
spinner_multi_start() {
	export SPINNER_TASK_COUNT=0
	export SPINNER_TASK_SUCCESS=0
	export SPINNER_TASK_FAILED=0
	tput civis 2>/dev/null || true
}

spinner_task() {
	local task_name="$1"
	shift
	local cmd=("$@")
	local CLEAR_LINE="\033[K"
	local SPINNER_PID_FILE="$(mktemp)"
	
	((SPINNER_TASK_COUNT++))
	
	# Set up spinner frames
	local frames=("⣾" "⣽" "⣻" "⢿" "⡿" "⣟" "⣯" "⣷")
	local interval=0.08
	
	# Start animated spinner in background
	(
		while [[ -f "$SPINNER_PID_FILE" ]]; do
			for frame in "${frames[@]}"; do
				[[ ! -f "$SPINNER_PID_FILE" ]] && break
				printf "\r${COLOR_BOLD_CYAN}${frame}${NC}  ${task_name}${CLEAR_LINE}"
				sleep "$interval"
			done
		done
	) &
	local spinner_pid=$!
	
	# Execute command
	local exit_code=0
	"${cmd[@]}" &>/dev/null || exit_code=$?
	
	# Stop spinner
	rm -f "$SPINNER_PID_FILE"
	kill "$spinner_pid" 2>/dev/null || true
	wait "$spinner_pid" 2>/dev/null || true
	
	# Show final result
	if [[ $exit_code -eq 0 ]]; then
		printf "\r${COLOR_BOLD_GREEN}✔${NC}  ${task_name}${CLEAR_LINE}\n"
		((SPINNER_TASK_SUCCESS++))
	else
		printf "\r${COLOR_BOLD_RED}✗${NC}  ${task_name}${CLEAR_LINE}\n"
		((SPINNER_TASK_FAILED++))
	fi
	
	return $exit_code
}

spinner_multi_finish() {
	local CLEAR_LINE="\033[K"
	tput cnorm 2>/dev/null || true
	
	if [[ ${SPINNER_TASK_FAILED:-0} -eq 0 ]]; then
		printf "\n${COLOR_GREEN}All tasks completed successfully!${NC} (${SPINNER_TASK_SUCCESS}/${SPINNER_TASK_COUNT})${CLEAR_LINE}\n"
	else
		printf "\n${COLOR_YELLOW}Completed with errors.${NC} Success: ${SPINNER_TASK_SUCCESS}, Failed: ${SPINNER_TASK_FAILED}${CLEAR_LINE}\n"
	fi
	
	unset SPINNER_TASK_COUNT SPINNER_TASK_SUCCESS SPINNER_TASK_FAILED
}

# Cleanup function for trapped exits
spinner_cleanup() {
	if [[ -n "${SPINNER_PID_FILE:-}" && -f "$SPINNER_PID_FILE" ]]; then
		local spinner_pid
		spinner_pid=$(<"$SPINNER_PID_FILE")
		rm -f "$SPINNER_PID_FILE"
		kill "$spinner_pid" 2>/dev/null || true
		wait "$spinner_pid" 2>/dev/null || true
		unset SPINNER_PID_FILE
	fi
	tput cnorm 2>/dev/null || true
}

# Set up cleanup trap
trap spinner_cleanup EXIT INT TERM
