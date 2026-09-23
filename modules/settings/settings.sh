#!/usr/bin/env bash

settings_theme() {
    printf 'Theme: SHΛYEN Dark / Silent Sovereign\n'
}

settings_language() {
    printf 'Language: English\n'
}

settings_editor() {
    printf 'Editor: %s\n' "${EDITOR:-auto}"
}

settings_paths() {
    printf 'ROOT : %s\n' "$SHAYEN_ROOT"
    printf 'DATA : %s\n' "$SHAYEN_DATA_DIR"
    printf 'LOGS : %s\n' "$SHAYEN_LOG_DIR"
}

settings_logs() {
    if [ -f "$SHAYEN_LOG_DIR/shayeen.log" ]; then
        tail -100 "$SHAYEN_LOG_DIR/shayeen.log"
    else
        printf 'No logs yet.\n'
    fi
}

settings_update() {
    if [ -d "$SHAYEN_ROOT/.git" ]; then
        git -C "$SHAYEN_ROOT" pull --ff-only
    else
        warn "SHΛYEN is not a Git working tree."
    fi
}
