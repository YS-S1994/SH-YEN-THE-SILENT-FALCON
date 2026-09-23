#!/data/data/com.termux/files/usr/bin/bash

file_info() {
    local file="$1"

    if [ -z "$file" ]; then
        echo "Usage: shΛheen files info <file>"
        return 1
    fi

    if [ ! -e "$file" ]; then
        echo "File not found."
        return 1
    fi

    ls -lah "$file"
    file "$file" 2>/dev/null || true
}
