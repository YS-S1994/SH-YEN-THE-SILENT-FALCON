#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$ROOT/bin/shayeen"
chmod +x "$ROOT"/core/*.sh
chmod +x "$ROOT"/modules/*/*.sh

if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
    TARGET="$PREFIX/bin"
else
    TARGET="$HOME/.local/bin"
    mkdir -p "$TARGET"
fi

ln -sf "$ROOT/bin/shayeen" "$TARGET/shayeen"
ln -sf "$ROOT/bin/shayeen" "$TARGET/shaheen"
ln -sf "$ROOT/bin/shayeen" "$TARGET/sn"

cat > "$ROOT/uninstall.sh" <<'EOF'
#!/usr/bin/env bash

TARGET="${PREFIX:-$HOME/.local}/bin"

rm -f "$TARGET/shayeen"
rm -f "$TARGET/shaheen"
rm -f "$TARGET/sn"

echo "SHΛYEN command links removed."
EOF

chmod +x "$ROOT/uninstall.sh"

cat > "$ROOT/tests/test.sh" <<'EOF'
#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/shayeen"

pass=0
fail=0

test_command() {
    local name="$1"
    shift

    printf '%-35s' "$name"

    if "$@" >/dev/null 2>&1; then
        printf ' OK\n'
        pass=$((pass + 1))
    else
        printf ' FAIL\n'
        fail=$((fail + 1))
    fi
}

test_command "Version" "$CLI" --version
test_command "Help" "$CLI" --help
test_command "System info" "$CLI" system info
test_command "System CPU" "$CLI" system cpu
test_command "System memory" "$CLI" system memory
test_command "System storage" "$CLI" system storage
test_command "System environment" "$CLI" system environment
test_command "Network interfaces" "$CLI" network interfaces
test_command "Network routes" "$CLI" network routes
test_command "Network DNS" "$CLI" network dns
test_command "Network diagnostics" "$CLI" network diagnostics
test_command "Security audit" "$CLI" security audit
test_command "Security environment" "$CLI" security environment
test_command "Security permissions" "$CLI" security permissions
test_command "Crypto hash" "$CLI" crypto hash "$ROOT/VERSION"
test_command "Crypto SHA256" "$CLI" crypto sha256 "$ROOT/VERSION"
test_command "Crypto SHA512" "$CLI" crypto sha512 "$ROOT/VERSION"
test_command "Files search" "$CLI" files search VERSION "$ROOT"
test_command "Developer detect" "$CLI" dev detect
test_command "Storage status" "$CLI" storage status
test_command "Settings paths" "$CLI" settings paths
test_command "Utilities UUID" "$CLI" utils uuid
test_command "Utilities timestamp" "$CLI" utils timestamp

echo
echo "Passed : $pass"
echo "Failed : $fail"

[ "$fail" -eq 0 ]
EOF

chmod +x "$ROOT/tests/test.sh"

echo
echo "============================================================"
echo " SHΛYEN — THE SILENT SOVEREIGN"
echo "============================================================"
echo

echo "Testing executable..."
"$ROOT/bin/shayeen" --version

echo
echo "Running validation..."
"$ROOT/tests/test.sh"

echo
echo "Checking installed commands..."

if command -v shayeen >/dev/null 2>&1; then
    echo "shayeen : $(command -v shayeen)"
else
    echo "shayeen is installed but current PATH may need refreshing."
fi

if command -v sn >/dev/null 2>&1; then
    echo "sn      : $(command -v sn)"
else
    echo "sn is installed but current PATH may need refreshing."
fi

echo
echo "============================================================"
echo " INSTALLATION COMPLETE"
echo "============================================================"
echo
echo "Identity:"
echo "  SHΛYEN — THE SILENT SOVEREIGN"
echo "  SHAY-EN"
echo "  SYN"
echo "  SΛYEN."
echo "  SYN-94"
echo
echo "Prompt:"
echo "  ⟦SN-🜏⟧ ~/shaheen \$"
echo
echo "Commands:"
echo "  shayeen"
echo "  shaheen"
echo "  sn"
echo
