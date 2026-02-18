#!/bin/bash

clear_python_caches() {
	if command -v log_func_start >/dev/null 2>&1; then
		log_func_start "clear_python_caches"
	fi
	if command -v log_process_start >/dev/null 2>&1; then
		log_process_start "Clearing Python caches"
	fi
	if command -v log_debug >/dev/null 2>&1; then
		log_debug "Removing __pycache__, .mypy_cache, and .pytest_cache directories"
	fi
	find . -type d \( -name "__pycache__" -o -name ".mypy_cache" -o -name ".pytest_cache" \) -exec rm -r {} +
	if command -v log_debug >/dev/null 2>&1; then
		log_debug "Removing *.pyc files"
	fi
	find . -name "*.pyc" -delete
	if command -v log_process_complete >/dev/null 2>&1; then
		log_process_complete "Python caches cleared"
	fi
	if command -v log_func_end >/dev/null 2>&1; then
		log_func_end "clear_python_caches"
	fi
}
