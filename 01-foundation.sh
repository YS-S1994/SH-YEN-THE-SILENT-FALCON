#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p \
  "$ROOT/bin" \
  "$ROOT/core" \
  "$ROOT/modules"/{network,security,system,crypto,download,files,search,monitor,developer,build,storage,utilities,settings} \
  "$ROOT/assets/logo" \
  "$ROOT/assets/reference" \
  "$ROOT/config" \
  "$ROOT/data" \
  "$ROOT/logs" \
  "$ROOT/tests" \
  "$ROOT/docs"

printf '%s\n' '1.0.0' > "$ROOT/VERSION"

cat > "$ROOT/core/config.sh" <<'EOF'
#!/usr/bin/env bash

SHAYEN_VERSION="1.0.0"
SHAYEN_NAME="SHΛYEN"
SHAYEN_PRONUNCIATION="SHAY-EN"
SHAYEN_ABBR="SYN"
SHAYEN_SIGNATURE="SΛYEN."
SHAYEN_TITLE="THE SILENT SOVEREIGN"
SHAYEN_SYMBOL="Λ"
SHAYEN_NUMBER="94"
SHAYEN_PROMPT="⟦SN-🜏⟧"
SHAYEN_MOTTO="KNOW • BUILD • PROTECT"
SHAYEN_PLATFORM="Termux / Android"

SHAYEN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHAYEN_CONFIG_DIR="$SHAYEN_ROOT/config"
SHAYEN_DATA_DIR="$SHAYEN_ROOT/data"
SHAYEN_LOG_DIR="$SHAYEN_ROOT/logs"

export SHAYEN_VERSION
export SHAYEN_NAME
export SHAYEN_PRONUNCIATION
export SHAYEN_ABBR
export SHAYEN_SIGNATURE
export SHAYEN_TITLE
export SHAYEN_SYMBOL
export SHAYEN_NUMBER
export SHAYEN_PROMPT
export SHAYEN_MOTTO
export SHAYEN_PLATFORM
export SHAYEN_ROOT
export SHAYEN_CONFIG_DIR
export SHAYEN_DATA_DIR
export SHAYEN_LOG_DIR
EOF

cat > "$ROOT/core/ui.sh" <<'EOF'
#!/usr/bin/env bash

ESC=$'\033'

RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"

BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"

BRIGHT_BLACK="${ESC}[90m"
BRIGHT_RED="${ESC}[91m"
BRIGHT_GREEN="${ESC}[92m"
BRIGHT_YELLOW="${ESC}[93m"
BRIGHT_BLUE="${ESC}[94m"
BRIGHT_MAGENTA="${ESC}[95m"
BRIGHT_CYAN="${ESC}[96m"
BRIGHT_WHITE="${ESC}[97m"

line() {
    printf '%s\n' "${BRIGHT_BLACK}────────────────────────────────────────────────────────────────${RESET}"
}

title() {
    printf '\n%s%s%s\n' "$BOLD" "$BRIGHT_WHITE" "$1"
    line
}

info() {
    printf '%s[INFO]%s %s\n' "$BRIGHT_CYAN" "$RESET" "$1"
}

ok() {
    printf '%s[ OK ]%s %s\n' "$BRIGHT_GREEN" "$RESET" "$1"
}

warn() {
    printf '%s[WARN]%s %s\n' "$BRIGHT_YELLOW" "$RESET" "$1"
}

err() {
    printf '%s[ERR ]%s %s\n' "$BRIGHT_RED" "$RESET" "$1"
}

section() {
    printf '\n%s%s%s\n' "$BOLD" "$BRIGHT_CYAN" "$1"
}

prompt() {
    printf '%s%s ~/shaheen $ %s' "$BRIGHT_MAGENTA" "⟦SN-🜏⟧" "$RESET"
}

pause() {
    printf '\n%sPress Enter to continue...%s' "$DIM" "$RESET"
    read -r
}

box() {
    local text="$1"
    printf '%s┌──────────────────────────────────────────────────────────────┐%s\n' "$BRIGHT_BLACK" "$RESET"
    printf '%s│%s %-60s %s│%s\n' "$BRIGHT_BLACK" "$BRIGHT_WHITE" "$text" "$BRIGHT_BLACK" "$RESET"
    printf '%s└──────────────────────────────────────────────────────────────┘%s\n' "$BRIGHT_BLACK" "$RESET"
}

falcon_logo() {
    printf '%s\n' "${BRIGHT_CYAN}"
    printf '                         /\\\n'
    printf '                _______/  \\_______\n'
    printf '           ____/                  \\____\n'
    printf '       ___/     __            __       \\___\n'
    printf '     _/        /  \\__________/  \\         \\_\n'
    printf '    /         /                    \\         \\\n'
    printf '   /_________/     SHΛYEN           \\_________\\\n'
    printf '             \\   THE SILENT   /\n'
    printf '              \\   SOVEREIGN  /\n'
    printf '               \\___________/\n'
    printf '%s\n' "$RESET"

    printf '%s%sSHΛYEN%s\n' "$BOLD" "$BRIGHT_WHITE" "$RESET"
    printf '%sTHE SILENT SOVEREIGN%s\n' "$BRIGHT_CYAN" "$RESET"
    printf '%sSYN-94%s\n' "$BRIGHT_MAGENTA" "$RESET"
    printf '%s%s%s\n' "$BRIGHT_WHITE" "KNOW • BUILD • PROTECT" "$RESET"
}

header() {
    clear 2>/dev/null || true
    falcon_logo
    printf '\n'
    printf '%s%s%s ~/shaheen $ %s\n' "$BRIGHT_MAGENTA" "⟦SN-🜏⟧" "$BRIGHT_WHITE" "$RESET"
}
EOF

cat > "$ROOT/core/environment.sh" <<'EOF'
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
EOF

cat > "$ROOT/core/logger.sh" <<'EOF'
#!/usr/bin/env bash

shayeen_log() {
    mkdir -p "$SHAYEN_LOG_DIR"
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" \
        >> "$SHAYEN_LOG_DIR/shayeen.log"
}
EOF

chmod +x "$ROOT"/core/*.sh

echo
echo "============================================================"
echo " SHΛYEN FOUNDATION READY"
echo " THE SILENT SOVEREIGN"
echo "============================================================"
echo
echo "Version : 1.0.0"
echo "Prompt  : ⟦SN-🜏⟧ ~/shaheen \$"
echo
