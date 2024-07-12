#!/bin/bash

show_help() {
    echo "Usage: ./find3rr.sh [option] [value]"
    echo "Options:"
    echo "  -f filename  Search for a file with the given name."
    echo "  -d directory Search for a directory with the given name."
    echo "  -t text      Search for a text string within files."
    echo "  -h           Display this help message."
}

check_requirements() {
    if ! command -v find &> /dev/null; then
        echo "find command is required but not found. Please install it."
        exit 1
    fi
    
    if ! command -v grep &> /dev/null; then
        echo "grep command is required but not found. Please install it."
        exit 1
    fi
    
    if ! command -v tree &> /dev/null; then
        echo "tree command is required but not found. Install it with: sudo apt-get install tree (Debian-based) or sudo yum install tree (RHEL-based)."
        tree_installed=0
    else
        tree_installed=1
    fi
}

search_file() {
    local filename=$1
    echo "Searching for file: $filename"
    if [ $tree_installed -eq 1 ]; then
        find . -type f -name "$filename" -print | while read -r line; do
            tree -L 1 "$(dirname "$line")"
        done
    else
        find . -type f -name "$filename"
    fi
}

search_directory() {
    local dirname=$1
    echo "Searching for directory: $dirname"
    if [ $tree_installed -eq 1 ]; then
        find . -type d -name "$dirname" -print | while read -r line; do
            tree -L 1 "$line"
        done
    else
        find . -type d -name "$dirname"
    fi
}

search_text() {
    local text=$1
    echo "Searching for text: $text"
    if [ $tree_installed -eq 1 ]; then
        grep -rnl . -e "$text" | while read -r line; do
            tree -L 1 "$(dirname "$line")"
        done
    else
        grep -rnl . -e "$text"
    fi
}

check_requirements

while getopts ":f:d:t:h" opt; do
    case $opt in
        f)
            search_file "$OPTARG"
            ;;
        d)
            search_directory "$OPTARG"
            ;;
        t)
            search_text "$OPTARG"
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    show_help
    exit 1
fi
