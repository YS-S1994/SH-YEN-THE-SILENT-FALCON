#!/data/data/com.termux/files/usr/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="$PREFIX/bin/shayeen"

echo "Installing SHΛHEEN Toolkit..."

chmod +x "$PROJECT_DIR/bin/shayeen"

ln -sf "$PROJECT_DIR/bin/shayeen" "$TARGET"

echo
echo "SHΛHEEN Toolkit installed."
echo
echo "Run:"
echo "  shayeen"
echo
