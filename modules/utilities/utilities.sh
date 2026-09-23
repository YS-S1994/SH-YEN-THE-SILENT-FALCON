#!/usr/bin/env bash

utils_json() {
    if command -v jq >/dev/null 2>&1; then
        jq .
    else
        warn "jq is not installed."
    fi
}

utils_base64() {
    printf '%s' "$1" | base64
}

utils_timestamp() {
    date '+%Y-%m-%d %H:%M:%S %z'
}

utils_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    else
        cat /proc/sys/kernel/random/uuid 2>/dev/null ||
        openssl rand -hex 16
    fi
}

utils_calculator() {
    command -v bc >/dev/null 2>&1 || {
        warn "bc is not installed."
        return 1
    }
    printf '%s\n' "$1" | bc -l
}

utils_random() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 32
    else
        od -An -N32 -tx1 /dev/urandom | tr -d ' \n'
        printf '\n'
    fi
}

utils_qr() {
    if command -v qrencode >/dev/null 2>&1; then
        qrencode -t UTF8 "$1"
    else
        warn "qrencode is not installed."
    fi
}

utils_archive() {
    files_compress "$@"
}
