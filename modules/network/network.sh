#!/usr/bin/env bash

network_interfaces() {
    title "NETWORK / INTERFACES"

    if command -v ip >/dev/null 2>&1; then
        local output
        output="$(ip -brief addr 2>&1 || true)"

        if printf '%s\n' "$output" | grep -qiE 'permission denied|cannot bind|operation not permitted'; then
            warn "Interface information is restricted by Android/SELinux."

            if command -v ifconfig >/dev/null 2>&1; then
                ifconfig 2>/dev/null || true
            fi
        elif [ -n "$output" ]; then
            printf '%s\n' "$output"
        else
            warn "No interface information available."
        fi

    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig 2>/dev/null || warn "Interface information unavailable."

    else
        warn "Neither ip nor ifconfig is available."
    fi
}

network_routes() {
    title "NETWORK / ROUTES"

    if command -v ip >/dev/null 2>&1; then
        local output
        output="$(ip route 2>&1 || true)"

        if printf '%s\n' "$output" | grep -qiE 'permission denied|cannot bind|operation not permitted'; then
            warn "Routing information is restricted by Android/SELinux."
        elif [ -n "$output" ]; then
            printf '%s\n' "$output"
        else
            warn "No routing information available."
        fi
    else
        warn "ip command is not installed."
    fi
}

network_dns() {
    title "NETWORK / DNS"

    printf 'Resolver configuration:\n'

    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf
        return 0
    fi

    if command -v getprop >/dev/null 2>&1; then
        local found=0
        local dns

        for dns in \
            "$(getprop net.dns1 2>/dev/null)" \
            "$(getprop net.dns2 2>/dev/null)" \
            "$(getprop net.dns3 2>/dev/null)" \
            "$(getprop net.dns4 2>/dev/null)"
        do
            if [ -n "$dns" ]; then
                printf 'DNS: %s\n' "$dns"
                found=1
            fi
        done

        if [ "$found" -eq 1 ]; then
            return 0
        fi
    fi

    if command -v nslookup >/dev/null 2>&1; then
        nslookup example.com 2>/dev/null || true
        return 0
    fi

    warn "DNS configuration is unavailable through the current Termux/Android environment."
}

network_connectivity() {
    title "NETWORK / CONNECTIVITY"

    if ! command -v curl >/dev/null 2>&1; then
        warn "curl is not installed."
        return 0
    fi

    if curl -fsS --max-time 7 https://example.com >/dev/null 2>&1; then
        ok "Internet connectivity: reachable"
    else
        warn "Internet connectivity: unavailable"
    fi
}

network_public_ip() {
    title "NETWORK / PUBLIC IP"

    if ! command -v curl >/dev/null 2>&1; then
        warn "curl is not installed."
        return 0
    fi

    local ip
    ip="$(curl -fsS --max-time 7 https://api.ipify.org 2>/dev/null || true)"

    if [ -n "$ip" ]; then
        printf '%s\n' "$ip"
    else
        warn "Unable to determine public IP."
    fi
}

network_ports() {
    title "NETWORK / LOCAL PORTS"

    if command -v ss >/dev/null 2>&1; then
        local output

        output="$(ss -lntup 2>&1 || true)"

        if printf '%s\n' "$output" | grep -qiE 'permission denied|operation not permitted'; then
            output="$(ss -lntu 2>/dev/null || true)"
        fi

        if [ -n "$output" ]; then
            printf '%s\n' "$output"
        else
            warn "No listening sockets available."
        fi

    elif command -v netstat >/dev/null 2>&1; then
        netstat -lntu 2>/dev/null || true

    else
        warn "Install iproute2 or net-tools for local port inspection."
    fi
}

network_diagnostics() {
    title "NETWORK / DIAGNOSTICS"

    network_interfaces
    printf '\n'

    network_routes
    printf '\n'

    network_dns
    printf '\n'

    network_connectivity
    printf '\n'

    network_public_ip
    printf '\n'

    network_ports
}
