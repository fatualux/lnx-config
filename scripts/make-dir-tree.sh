#!/bin/bash
# make-dir-tree.sh
# Generate a directory tree structure and write it to a markdown file
# Uses ls and ASCII characters to draw tree branches

set -euo pipefail

# Default values
OUTPUT_FILE="structure.md"
SHOW_HIDDEN=false
MAX_DEPTH=-1
IGNORE_DIRS=()

# Usage information
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <directory> [output_file]

Generate a directory tree structure and write it to a markdown file.

Arguments:
  directory           The directory to generate the tree from
  output_file         Optional output file (default: structure.md)

Options:
  --help              Display this help message
  -a                  Include hidden files and directories
  -d <depth>          Maximum depth to display (default: unlimited)
  -i <dirs>           Directories to ignore (comma-separated)

Examples:
  $(basename "$0") /path/to/directory
  $(basename "$0") /path/to/directory output.md
  $(basename "$0") -a -d 3 /path/to/directory
  $(basename "$0") -i "node_modules,.git" /path/to/directory

EOF
    exit 0
}

# Error handling
error() {
    echo "Error: $1" >&2
    exit 1
}

# Parse command-line arguments
parse_args() {
    local positional_args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                ;;
            -a)
                SHOW_HIDDEN=true
                shift
                ;;
            -d)
                if [[ -z "${2:-}" ]] || [[ ! "$2" =~ ^[0-9]+$ ]]; then
                    error "Option -d requires a numeric argument"
                fi
                MAX_DEPTH="$2"
                shift 2
                ;;
            -i)
                if [[ -z "${2:-}" ]]; then
                    error "Option -i requires an argument"
                fi
                IFS=',' read -ra IGNORE_DIRS <<< "$2"
                shift 2
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Validate positional arguments
    if [[ ${#positional_args[@]} -eq 0 ]]; then
        error "Missing required argument: directory"
    fi
    
    TARGET_DIR="${positional_args[0]}"
    
    if [[ ${#positional_args[@]} -ge 2 ]]; then
        OUTPUT_FILE="${positional_args[1]}"
    fi
    
    # Validate directory exists
    if [[ ! -d "$TARGET_DIR" ]]; then
        error "Directory does not exist: $TARGET_DIR"
    fi
}

# Check if directory should be ignored
should_ignore() {
    local dir_name="$1"
    
    for ignore_pattern in "${IGNORE_DIRS[@]}"; do
        if [[ "$dir_name" == "$ignore_pattern" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Generate tree structure recursively
generate_tree() {
    local dir="$1"
    local prefix="$2"
    local current_depth="${3:-0}"
    
    # Check depth limit
    if [[ $MAX_DEPTH -ge 0 ]] && [[ $current_depth -ge $MAX_DEPTH ]]; then
        return
    fi
    
    # Build ls options
    local ls_opts="-1"
    if [[ "$SHOW_HIDDEN" == true ]]; then
        ls_opts="${ls_opts}A"
    fi
    
    # Get list of items
    local items=()
    while IFS= read -r item; do
        # Skip . and ..
        if [[ "$item" == "." ]] || [[ "$item" == ".." ]]; then
            continue
        fi
        
        # Check if should ignore
        if should_ignore "$item"; then
            continue
        fi
        
        items+=("$item")
    done < <(ls $ls_opts "$dir" 2>/dev/null || true)
    
    # Process each item
    local total_items=${#items[@]}
    local item_index=0
    
    for item in "${items[@]}"; do
        item_index=$((item_index + 1))
        local item_path="$dir/$item"
        local is_last=false
        
        if [[ $item_index -eq $total_items ]]; then
            is_last=true
        fi
        
        # Determine tree characters
        if [[ $is_last == true ]]; then
            local connector="└── "
            local new_prefix="${prefix}    "
        else
            local connector="├── "
            local new_prefix="${prefix}│   "
        fi
        
        # Add item to output
        if [[ -d "$item_path" ]]; then
            echo "${prefix}${connector}${item}/"
            # Recurse into directory
            generate_tree "$item_path" "$new_prefix" $((current_depth + 1))
        else
            echo "${prefix}${connector}${item}"
        fi
    done
}

# Main execution
main() {
    parse_args "$@"
    
    # Get directory name
    local dir_name
    dir_name=$(basename "$TARGET_DIR")
    
    # Generate tree and write to file
    {
        echo "# Directory Structure"
        echo ""
        echo '```'
        echo "${dir_name}/"
        generate_tree "$TARGET_DIR" "" 0
        echo '```'
    } > "$OUTPUT_FILE"
    
    echo "Tree structure written to: $OUTPUT_FILE"
    
    # Display summary
    local line_count
    line_count=$(wc -l < "$OUTPUT_FILE")
    echo "Total lines: $line_count"
}

# Run main function
main "$@"
