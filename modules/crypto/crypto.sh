#!/data/data/com.termux/files/usr/bin/bash

crypto_hash() {
    local file="$1"

    if [ -z "$file" ]; then
        echo "Usage: shΛheen crypto hash <file>"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi

    echo
    echo "SHA-256:"
    sha256sum "$file"

    echo
    echo "SHA-512:"
    sha512sum "$file"
}
