#!/data/data/com.termux/files/usr/bin/bash

system_info() {
    echo
    echo "=== SYSTEM INFORMATION ==="
    echo

    echo "OS:"
    uname -o 2>/dev/null || uname -s

    echo "Kernel:"
    uname -r

    echo "Architecture:"
    uname -m

    echo "Hostname:"
    hostname

    echo
    echo "Termux:"
    echo "${PREFIX:-Unknown}"
}
