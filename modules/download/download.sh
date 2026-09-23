#!/data/data/com.termux/files/usr/bin/bash

download_file() {
    local url="$1"

    if [ -z "$url" ]; then
        echo "Usage: shΛheen download <URL>"
        return 1
    fi

    curl -fL --progress-bar -O "$url"
}
