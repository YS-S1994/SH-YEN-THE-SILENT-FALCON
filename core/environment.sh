#!/usr/bin/env bash

detect_environment() {
    if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
        printf '%s\n' "TERMUX"
        return
    fi

    if [ -r /etc/os-release ]; then
        . /etc/os-release
        case "${ID:-}" in
            kali) printf '%s\n' "KALI"; return ;;
            debian) printf '%s\n' "DEBIAN"; return ;;
            ubuntu) printf '%s\n' "UBUNTU"; return ;;
            alpine) printf '%s\n' "ALPINE"; return ;;
        esac
    fi

    printf '%s\n' "LINUX"
}

environment_name() {
    case "$(detect_environment)" in
        TERMUX) echo "Termux / Android" ;;
        KALI) echo "Kali Linux" ;;
        DEBIAN) echo "Debian Linux" ;;
        UBUNTU) echo "Ubuntu Linux" ;;
        ALPINE) echo "Alpine Linux" ;;
        *) echo "Linux" ;;
    esac
}
