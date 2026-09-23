#!/usr/bin/env bash

security_audit() {
    title "SECURITY / LOCAL AUDIT"

    printf 'User:\n'
    id 2>/dev/null || true

    printf '\nPATH:\n%s\n' "$PATH"

    printf '\nLocal listening sockets:\n'
    if command -v ss >/dev/null 2>&1; then
        ss -lntup 2>/dev/null || true
    else
        warn "ss unavailable."
    fi

    printf '\nWorld-writable files in HOME:\n'
    find "$HOME" -type f -perm -0002 2>/dev/null | head -100 || true
}

security_permissions() {
    title "SECURITY / PERMISSIONS"
    local target="${1:-$HOME}"
    ls -ld "$target" 2>/dev/null || err "Cannot inspect: $target"
}

security_hashes() {
    title "SECURITY / HASHES"
    local target="${1:-}"
    if [ -f "$target" ]; then
        sha256sum "$target"
        sha512sum "$target"
    else
        find "$HOME" -maxdepth 2 -type f 2>/dev/null | head -50
    fi
}

security_certificates() {
    title "SECURITY / CERTIFICATES"

    if command -v openssl >/dev/null 2>&1; then
        openssl version
        printf '\nSystem certificate locations:\n'
        for p in \
            /etc/ssl/certs \
            "$PREFIX/etc/tls/certificates" \
            "$PREFIX/etc/ssl/certs"
        do
            [ -d "$p" ] && printf '  %s\n' "$p"
        done
    else
        warn "OpenSSL unavailable."
    fi
}

security_files() {
    title "SECURITY / FILES"

    find "$HOME" -maxdepth 3 -type f \
        \( -name '*.key' -o -name '*.pem' -o -name '*.crt' \) \
        2>/dev/null | head -100
}

security_environment() {
    title "SECURITY / ENVIRONMENT"

    env | grep -Ei 'token|password|secret|api[_-]?key|credential' \
        | sed 's/=.*$/=<redacted>/' \
        | head -100 || true
}

security_report() {
    title "SECURITY / REPORT"

    {
        echo "SHΛYEN SECURITY REPORT"
        echo "Generated: $(date)"
        echo "Environment: $(environment_name)"
        echo
        security_audit
        echo
        security_environment
    } > "$SHAYEN_LOG_DIR/security-report.txt"

    ok "Report: $SHAYEN_LOG_DIR/security-report.txt"
}
