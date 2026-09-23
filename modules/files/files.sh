#!/usr/bin/env bash

files_info() {
    local target="$1"

    title "FILES / INFORMATION"

    if [ -z "$target" ]; then
        err "Usage: shayeen files info <file>"
        return 1
    fi

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        err "File or directory not found: $target"
        return 1
    fi

    printf 'Path        : %s\n' "$(realpath "$target" 2>/dev/null || printf '%s' "$target")"

    if [ -L "$target" ]; then
        printf 'Type        : symbolic link\n'
        printf 'Target      : %s\n' "$(readlink "$target" 2>/dev/null || true)"
    elif [ -d "$target" ]; then
        printf 'Type        : directory\n'
    elif [ -f "$target" ]; then
        printf 'Type        : regular file\n'
    else
        printf 'Type        : special file\n'
    fi

    if command -v stat >/dev/null 2>&1; then
        printf 'Size        : %s bytes\n' "$(stat -c '%s' "$target" 2>/dev/null || echo '?')"
        printf 'Permissions : %s\n' "$(stat -c '%A' "$target" 2>/dev/null || echo '?')"
        printf 'Owner       : %s:%s\n' \
            "$(stat -c '%U' "$target" 2>/dev/null || echo '?')" \
            "$(stat -c '%G' "$target" 2>/dev/null || echo '?')"
        printf 'Modified    : %s\n' "$(stat -c '%y' "$target" 2>/dev/null || echo '?')"
    fi

    if [ -f "$target" ]; then
        if command -v file >/dev/null 2>&1; then
            printf 'MIME/Type   : '
            file -b "$target" 2>/dev/null || true
        fi
    fi
}

files_search() {
    local pattern="$1"
    local path="${2:-$HOME}"

    if [ -z "$pattern" ]; then
        err "Usage: shayeen files search <pattern> [path]"
        return 1
    fi

    if [ ! -e "$path" ]; then
        err "Search path not found: $path"
        return 1
    fi

    title "FILES / SEARCH"

    find "$path" -iname "*$pattern*" 2>/dev/null | head -300
}

files_copy() {
    [ -n "$1" ] || {
        err "Usage: shayeen files copy <source> <destination>"
        return 1
    }

    [ -n "$2" ] || {
        err "Usage: shayeen files copy <source> <destination>"
        return 1
    }

    cp -a -- "$1" "$2"
    ok "Copied: $1 -> $2"
}

files_move() {
    [ -n "$1" ] || {
        err "Usage: shayeen files move <source> <destination>"
        return 1
    }

    [ -n "$2" ] || {
        err "Usage: shayeen files move <source> <destination>"
        return 1
    }

    mv -- "$1" "$2"
    ok "Moved: $1 -> $2"
}

files_rename() {
    [ -n "$1" ] || {
        err "Usage: shayeen files rename <old> <new>"
        return 1
    }

    [ -n "$2" ] || {
        err "Usage: shayeen files rename <old> <new>"
        return 1
    }

    mv -- "$1" "$2"
    ok "Renamed: $1 -> $2"
}

files_delete() {
    local target="$1"

    if [ -z "$target" ]; then
        err "Usage: shayeen files delete <file>"
        return 1
    fi

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        err "Target not found: $target"
        return 1
    fi

    printf 'Delete "%s"? [y/N] ' "$target"
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            rm -rf -- "$target"
            ok "Deleted: $target"
            ;;
        *)
            warn "Deletion cancelled."
            ;;
    esac
}

files_compress() {
    local source="$1"
    local output="${2:-archive.tar.gz}"

    if [ -z "$source" ]; then
        err "Usage: shayeen files compress <source> [archive.tar.gz]"
        return 1
    fi

    tar -czf "$output" "$source"
    ok "Created: $output"
}

files_extract() {
    local archive="$1"
    local destination="${2:-.}"

    if [ -z "$archive" ]; then
        err "Usage: shayeen files extract <archive> [destination]"
        return 1
    fi

    mkdir -p "$destination"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$destination"
            ;;
        *.tar)
            tar -xf "$archive" -C "$destination"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$destination"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$destination"
            ;;
        *.zip)
            if command -v unzip >/dev/null 2>&1; then
                unzip -q "$archive" -d "$destination"
            else
                err "unzip is not installed."
                return 1
            fi
            ;;
        *)
            err "Unsupported archive format: $archive"
            return 1
            ;;
    esac

    ok "Extracted: $archive -> $destination"
}

files_checksum() {
    local target="$1"

    if [ -z "$target" ]; then
        err "Usage: shayeen files checksum <file>"
        return 1
    fi

    if [ ! -f "$target" ]; then
        err "Regular file required: $target"
        return 1
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$target"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$target"
    else
        err "No SHA-256 utility available."
        return 1
    fi
}

files_permissions() {
    local target="$1"

    if [ -z "$target" ]; then
        err "Usage: shayeen files permissions <file>"
        return 1
    fi

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        err "Target not found: $target"
        return 1
    fi

    if command -v stat >/dev/null 2>&1; then
        stat "$target" 2>/dev/null
    else
        ls -ld "$target"
    fi
}
