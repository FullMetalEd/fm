#!/bin/bash
# ---
# name: mkf
# description: Creates a directory path and a file, then opens it in an editor.
# usage: mkf <path/to/file> [editor]
# example: mkf /tmp/mydir/myfile.txt nano
# ---

if [ -z "$1" ]; then
    echo "Error: No file path provided."
    exit 1
fi

file_path="$1"
editor="${2:-nano}" # Default to nano if no editor is specified

# Extract directory path
dir_path="$(dirname "$file_path")"

# Create directory if it doesn't exist
if [ ! -d "$dir_path" ]; then
    mkdir -p "$dir_path"
fi

# Create the file if it doesn't exist
if [ ! -f "$file_path" ]; then
    touch "$file_path"
fi

# Open the file in the specified editor
"$editor" "$file_path"