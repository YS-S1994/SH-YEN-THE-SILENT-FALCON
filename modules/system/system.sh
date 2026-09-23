#!/usr/bin/env bash

system_info() {
    title "SYSTEM / INFORMATION"

    printf 'OS           : '
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        printf '%s\n' "${PRETTY_NAME:-Unknown}"
    else
        uname -s
    fi

    printf 'Kernel       : '; uname -sr
    printf 'Architecture : '; uname -m
    printf 'Hostname     : '; hostname 2>/dev/null || true
    printf 'Environment  : '; environment_name
    printf 'Shell        : '; printf '%s\n' "${SHELL:-unknown}"
}

system_cpu() {
    title "SYSTEM / CPU"

    if command -v nproc >/dev/null 2>&1; then
        printf 'CPU cores: %s\n' "$(nproc)"
    fi

    uname -m
    if [ -f /proc/cpuinfo ]; then
        grep -m1 -E 'model name|Hardware|Processor' /proc/cpuinfo 2>/dev/null || true
    fi
}

system_memory() {
    title "SYSTEM / MEMORY"

    if command -v free >/dev/null 2>&1; then
        free -h
    elif [ -r /proc/meminfo ]; then
        grep -E 'MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree' /proc/meminfo
    else
        warn "Memory information unavailable."
    fi
}

system_storage() {
    title "SYSTEM / STORAGE"
    df -h "$HOME" 2>/dev/null || df -h
}

system_processes() {
    title "SYSTEM / PROCESSES"
    ps aux 2>/dev/null || ps
}

system_packages() {
    title "SYSTEM / PACKAGES"

    if command -v pkg >/dev/null 2>&1; then
        pkg list-installed 2>/dev/null | head -100
    elif command -v dpkg >/dev/null 2>&1; then
        dpkg-query -W -f='${binary:Package}\n' 2>/dev/null | head -100
    else
        warn "No supported package database detected."
    fi
}

system_environment() {
    title "SYSTEM / ENVIRONMENT"
    printf 'PATH=%s\n' "$PATH"
    printf 'HOME=%s\n' "$HOME"
    printf 'PREFIX=%s\n' "${PREFIX:-not-set}"
    printf 'TERMUX_VERSION=%s\n' "${TERMUX_VERSION:-not-set}"
}

system_diagnose() {
    title "SYSTEM / DIAGNOSTICS"

    command -v bash >/dev/null && ok "bash"
    command -v curl >/dev/null && ok "curl"
    command -v git >/dev/null && ok "git"
    command -v python >/dev/null && ok "python" || true
    command -v node >/dev/null && ok "node" || true
    command -v go >/dev/null && ok "go" || true
    command -v rustc >/dev/null && ok "rust" || true
    command -v java >/dev/null && ok "java" || true
}
