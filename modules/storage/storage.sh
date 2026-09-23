#!/usr/bin/env bash

storage_setup() {
    if command -v termux-setup-storage >/dev/null 2>&1; then
        termux-setup-storage
    else
        warn "termux-setup-storage is available only in Termux."
    fi
}

storage_status() {
    title "STORAGE / STATUS"
    printf 'HOME   : %s\n' "$HOME"
    printf 'Shared : '

    if [ -d "$HOME/storage/shared" ]; then
        printf '%s\n' "$HOME/storage/shared"
    else
        printf 'not configured\n'
    fi

    df -h "$HOME" 2>/dev/null
}

storage_shared() {
    local path="$HOME/storage/shared"

    if [ -d "$path" ]; then
        ls -lah "$path"
    else
        warn "Termux shared storage is not configured."
    fi
}

storage_permissions() {
    ls -ld "$HOME/storage" "$HOME/storage/shared" 2>/dev/null
}

storage_scan() {
    find "$HOME/storage/shared" -maxdepth 3 -type f 2>/dev/null | head -300
}

storage_backup() {
    local source="${1:-$HOME/SHΛHEEN}"
    local outdir="$HOME/backups"

    mkdir -p "$outdir"

    local output="$outdir/SHΛHEEN_$(date +%Y%m%d_%H%M%S).tar.gz"

    tar -czf "$output" "$source"
    ok "Backup created: $output"
}
