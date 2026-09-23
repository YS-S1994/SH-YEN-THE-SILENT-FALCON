#!/usr/bin/env bash

search_files() {
    files_search "$@"
}

search_text() {
    local pattern="$1"
    local path="${2:-$HOME}"

    [ -n "$pattern" ] || return 1

    grep -RIn \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=.gradle \
        -- "$pattern" "$path" 2>/dev/null | head -300
}
