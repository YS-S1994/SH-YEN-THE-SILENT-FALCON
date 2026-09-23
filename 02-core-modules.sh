#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat > "$ROOT/modules/network/network.sh" <<'EOF'
#!/usr/bin/env bash

network_interfaces() {
    title "NETWORK / INTERFACES"
    if command -v ip >/dev/null 2>&1; then
        ip -brief addr 2>/dev/null || ip addr
    else
        warn "ip command is not installed."
    fi
}

network_routes() {
    title "NETWORK / ROUTES"
    if command -v ip >/dev/null 2>&1; then
        ip route 2>/dev/null || true
    else
        warn "ip command is not installed."
    fi
}

network_dns() {
    title "NETWORK / DNS"
    printf 'Resolver configuration:\n'
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
    else
        warn "/etc/resolv.conf unavailable."
    fi
}

network_connectivity() {
    title "NETWORK / CONNECTIVITY"
    if command -v curl >/dev/null 2>&1; then
        if curl -fsS --max-time 7 https://example.com >/dev/null; then
            ok "Internet connectivity: reachable"
        else
            warn "Internet connectivity: unavailable"
            return 1
        fi
    else
        warn "curl is not installed."
    fi
}

network_public_ip() {
    title "NETWORK / PUBLIC IP"
    if command -v curl >/dev/null 2>&1; then
        curl -fsS --max-time 7 https://api.ipify.org || warn "Unable to determine public IP."
        printf '\n'
    else
        warn "curl is not installed."
    fi
}

network_ports() {
    title "NETWORK / LOCAL PORTS"

    if command -v ss >/dev/null 2>&1; then
        ss -lntup 2>/dev/null || ss -lntu
    elif command -v netstat >/dev/null 2>&1; then
        netstat -lntup 2>/dev/null || netstat -lntu
    else
        warn "Install iproute2 or net-tools for local port inspection."
    fi
}

network_diagnostics() {
    title "NETWORK / DIAGNOSTICS"
    network_interfaces
    network_routes
    network_dns
    network_connectivity
}
EOF

cat > "$ROOT/modules/system/system.sh" <<'EOF'
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
EOF

cat > "$ROOT/modules/security/security.sh" <<'EOF'
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
EOF

cat > "$ROOT/modules/crypto/crypto.sh" <<'EOF'
#!/usr/bin/env bash

crypto_hash() {
    local file="$1"

    [ -f "$file" ] || {
        err "Usage: shayeen crypto hash <file>"
        return 1
    }

    printf 'SHA-256 : '
    sha256sum "$file"

    printf 'SHA-512 : '
    sha512sum "$file"
}

crypto_sha256() {
    sha256sum "$1"
}

crypto_sha512() {
    sha512sum "$1"
}

crypto_checksum() {
    local file="$1"
    [ -f "$file" ] || return 1
    sha256sum "$file"
}

crypto_keygen() {
    local output="${1:-shayeen.key}"

    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 32 > "$output"
        chmod 600 "$output"
        ok "Key material generated: $output"
    else
        err "OpenSSL is not installed."
        return 1
    fi
}

crypto_encrypt() {
    local input="$1"
    local output="${2:-$input.enc}"

    [ -f "$input" ] || {
        err "Input file not found."
        return 1
    }

    command -v gpg >/dev/null 2>&1 || {
        err "GPG is not installed."
        return 1
    }

    gpg --symmetric --output "$output" "$input"
    ok "Encrypted: $output"
}

crypto_decrypt() {
    local input="$1"
    local output="${2:-${input%.enc}}"

    [ -f "$input" ] || {
        err "Encrypted file not found."
        return 1
    }

    command -v gpg >/dev/null 2>&1 || {
        err "GPG is not installed."
        return 1
    }

    gpg --output "$output" --decrypt "$input"
    ok "Decrypted: $output"
}

crypto_sign() {
    local file="$1"
    [ -f "$file" ] || return 1
    command -v gpg >/dev/null 2>&1 || return 1
    gpg --armor --detach-sign "$file"
}

crypto_verify() {
    local signature="$1"
    local file="$2"

    command -v gpg >/dev/null 2>&1 || return 1
    gpg --verify "$signature" "$file"
}
EOF

chmod +x "$ROOT"/modules/{network,system,security,crypto}/*.sh

echo "CORE MODULES CREATED."
