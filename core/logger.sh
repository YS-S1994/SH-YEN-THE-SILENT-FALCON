#!/usr/bin/env bash

shayeen_log() {
    mkdir -p "$SHAYEN_LOG_DIR"
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" \
        >> "$SHAYEN_LOG_DIR/shayeen.log"
}
