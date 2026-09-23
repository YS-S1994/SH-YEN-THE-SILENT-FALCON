#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat > "$ROOT/modules/download/download.sh" <<'EOF'
#!/usr/bin/env bash

download_file() {
    local url="$1"
    [ -n "$url" ] || {
        err "Usage: shayeen download <URL>"
        return 1
    }

    command -v curl >/dev/null 2>&1 || {
        err "curl is not installed."
        return 1
    }

    curl -fL --progress-bar --remote-name "$url"
}

download_url() {
    download_file "$1"
}

download_checksum() {
    local file="$1"
    [ -f "$file" ] || return 1
    sha256sum "$file"
}

download_resume() {
    local url="$1"
    [ -n "$url" ] || return 1
    curl -fL -C - --progress-bar --remote-name "$url"
}

download_extract() {
    local archive="$1"
    local destination="${2:-.}"

    [ -f "$archive" ] || {
        err "Archive not found."
        return 1
    }

    mkdir -p "$destination"

    case "$archive" in
        *.tar.gz|*.tgz) tar -xzf "$archive" -C "$destination" ;;
        *.tar.xz) tar -xJf "$archive" -C "$destination" ;;
        *.tar.bz2) tar -xjf "$archive" -C "$destination" ;;
        *.tar) tar -xf "$archive" -C "$destination" ;;
        *.zip) unzip -o "$archive" -d "$destination" ;;
        *) err "Unsupported archive format."; return 1 ;;
    esac
}
EOF

cat > "$ROOT/modules/files/files.sh" <<'EOF'
#!/usr/bin/env bash

files_search() {
    local pattern="$1"
    local path="${2:-$HOME}"

    [ -n "$pattern" ] || return 1
    find "$path" -iname "*$pattern*" 2>/dev/null | head -300
}

files_copy() {
    cp -a -- "$1" "$2"
}

files_move() {
    mv -- "$1" "$2"
}

files_rename() {
    mv -- "$1" "$2"
}

files_delete() {
    local target="$1"

    [ -n "$target" ] || return 1

    printf 'Delete "%s"? [y/N] ' "$target"
    read -r answer

    case "$answer" in
        y|Y|yes|YES) rm -rf -- "$target" ;;
        *) warn "Deletion cancelled." ;;
    esac
}

files_compress() {
    local source="$1"
    local output="${2:-archive.tar.gz}"

    tar -czf "$output" "$source"
    ok "Created: $output"
}

files_extract() {
    download_extract "$1" "${2:-.}"
}

files_checksum() {
    sha256sum "$1"
}

files_permissions() {
    local target="$1"
    stat "$target" 2>/dev/null || ls -ld "$target"
}
EOF

cat > "$ROOT/modules/search/search.sh" <<'EOF'
#!/usr/bin/env bash

search_files() {
    files_search "$@"
}

search_text() {
    local pattern="$1"
    local path="${2:-$HOME}"

    [ -n "$pattern" ] || return 1

    grep -RIn \
        --exclude-dir=.git \
        --exclude-dir=node_modules \
        --exclude-dir=.gradle \
        -- "$pattern" "$path" 2>/dev/null | head -300
}
EOF

cat > "$ROOT/modules/monitor/monitor.sh" <<'EOF'
#!/usr/bin/env bash

monitor_processes() {
    ps aux 2>/dev/null || ps
}

monitor_memory() {
    system_memory
}

monitor_storage() {
    system_storage
}

monitor_network() {
    network_ports
}

monitor_all() {
    system_info
    system_memory
    system_storage
    network_ports
}
EOF

cat > "$ROOT/modules/developer/developer.sh" <<'EOF'
#!/usr/bin/env bash

dev_detect() {
    title "DEVELOPER / PROJECT DETECTION"

    local found=0

    [ -f "settings.gradle" ] || [ -f "settings.gradle.kts" ] || \
    [ -d "app/src" ] && {
        ok "Android"
        found=1
    }

    [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ] && {
        ok "Python"
        found=1
    }

    [ -f "package.json" ] && {
        ok "Node.js"
        found=1
    }

    [ -f "go.mod" ] && {
        ok "Go"
        found=1
    }

    [ -f "Cargo.toml" ] && {
        ok "Rust"
        found=1
    }

    find . -maxdepth 2 -type f \
        \( -name 'CMakeLists.txt' -o -name 'Makefile' -o -name '*.c' -o -name '*.cpp' -o -name '*.h' \) \
        2>/dev/null | grep . >/dev/null && {
            ok "C/C++"
            found=1
        }

    find . -maxdepth 2 -type f -name '*.java' 2>/dev/null | grep . >/dev/null && {
        ok "Java"
        found=1
    }

    [ "$found" -eq 0 ] && warn "No recognized project type detected."
}

dev_python() {
    command -v python3 >/dev/null 2>&1 && python3 --version ||
    command -v python >/dev/null 2>&1 && python --version ||
    warn "Python not installed."
}

dev_node() {
    command -v node >/dev/null 2>&1 && node --version || warn "Node.js not installed."
}

dev_go() {
    command -v go >/dev/null 2>&1 && go version || warn "Go not installed."
}

dev_rust() {
    command -v rustc >/dev/null 2>&1 && rustc --version || warn "Rust not installed."
}

dev_java() {
    command -v java >/dev/null 2>&1 && java -version 2>&1 | head -2 || warn "Java not installed."
}

dev_git() {
    command -v git >/dev/null 2>&1 && git --version || warn "Git not installed."
}

dev_environment() {
    printf 'Environment : %s\n' "$(environment_name)"
    printf 'Directory   : %s\n' "$PWD"
    printf 'Git         : '; dev_git
}
EOF

cat > "$ROOT/modules/storage/storage.sh" <<'EOF'
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
EOF

cat > "$ROOT/modules/utilities/utilities.sh" <<'EOF'
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
EOF

cat > "$ROOT/modules/settings/settings.sh" <<'EOF'
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
EOF

chmod +x "$ROOT"/modules/*/*.sh

echo "ALL TOOL MODULES CREATED."
