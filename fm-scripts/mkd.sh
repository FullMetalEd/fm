#!/bin/bash
# ---
# name: mkdir
# description: Creates a directory.
# usage: mkdir <path/to/dir>
# example: mkdir /tmp/mydir
# ---

if [ -z "$1" ]; then
    echo "Error: No directory path provided."
    exit 1
fi

dir_path="$1"

# Create directory if it doesn't exist
if [ ! -d "$dir_path" ]; then
    mkdir -p "$dir_path"
else
    echo "Error: Directory '$dir_path' already exists."
fi