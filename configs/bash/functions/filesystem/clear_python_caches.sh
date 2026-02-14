#!/bin/bash

clear_python_caches() {
	log_func_start "clear_python_caches"
	log_process_start "Clearing Python caches"
	log_debug "Removing __pycache__, .mypy_cache, and .pytest_cache directories"
	find . -type d \( -name "__pycache__" -o -name ".mypy_cache" -o -name ".pytest_cache" \) -exec rm -r {} +
	log_debug "Removing *.pyc files"
	find . -name "*.pyc" -delete
	log_process_complete "Python caches cleared"
	log_func_end "clear_python_caches"
}
