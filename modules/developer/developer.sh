#!/usr/bin/env bash

dev_detect() {
    local root="${1:-$PWD}"

    title "DEVELOPER / PROJECT DETECTION"

    if [ ! -d "$root" ]; then
        err "Directory not found: $root"
        return 1
    fi

    printf 'Project root: %s\n\n' "$(cd "$root" 2>/dev/null && pwd)"

    local found=0

    # Android / Gradle
    if [ -f "$root/settings.gradle" ] ||
       [ -f "$root/settings.gradle.kts" ] ||
       [ -f "$root/build.gradle" ] ||
       [ -f "$root/build.gradle.kts" ] ||
       [ -d "$root/app/src/main" ]; then
        ok "Android / Gradle"
        found=1
    fi

    # Python
    if [ -f "$root/pyproject.toml" ] ||
       [ -f "$root/requirements.txt" ] ||
       [ -f "$root/setup.py" ] ||
       [ -f "$root/Pipfile" ] ||
       [ -f "$root/poetry.lock" ]; then
        ok "Python"
        found=1
    fi

    # Node.js
    if [ -f "$root/package.json" ] ||
       [ -f "$root/package-lock.json" ] ||
       [ -f "$root/yarn.lock" ] ||
       [ -f "$root/pnpm-lock.yaml" ]; then
        ok "Node.js"
        found=1
    fi

    # Go
    if [ -f "$root/go.mod" ] ||
       [ -f "$root/go.sum" ]; then
        ok "Go"
        found=1
    fi

    # Rust
    if [ -f "$root/Cargo.toml" ] ||
       [ -f "$root/Cargo.lock" ]; then
        ok "Rust"
        found=1
    fi

    # C/C++
    if find "$root" -maxdepth 3 -type f \
        \( -name 'CMakeLists.txt' \
        -o -name 'Makefile' \
        -o -name '*.c' \
        -o -name '*.cc' \
        -o -name '*.cpp' \
        -o -name '*.cxx' \
        -o -name '*.h' \
        -o -name '*.hpp' \) \
        2>/dev/null | grep -q .; then
        ok "C/C++"
        found=1
    fi

    # Java
    if find "$root" -maxdepth 4 -type f -name '*.java' \
        2>/dev/null | grep -q .; then
        ok "Java"
        found=1
    fi

    # Git
    if [ -d "$root/.git" ] || git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
        ok "Git repository"
        found=1
    fi

    if [ "$found" -eq 0 ]; then
        warn "No recognized project type detected."
    fi
}

dev_python() {
    if command -v python3 >/dev/null 2>&1; then
        python3 --version
    elif command -v python >/dev/null 2>&1; then
        python --version
    else
        warn "Python not installed."
    fi
}

dev_node() {
    command -v node >/dev/null 2>&1 &&
        node --version ||
        warn "Node.js not installed."
}

dev_go() {
    command -v go >/dev/null 2>&1 &&
        go version ||
        warn "Go not installed."
}

dev_rust() {
    command -v rustc >/dev/null 2>&1 &&
        rustc --version ||
        warn "Rust not installed."
}

dev_java() {
    if command -v java >/dev/null 2>&1; then
        java -version 2>&1 | head -2
    else
        warn "Java not installed."
    fi
}

dev_git() {
    command -v git >/dev/null 2>&1 &&
        git --version ||
        warn "Git not installed."
}

dev_environment() {
    printf 'Environment : %s\n' "$(environment_name)"
    printf 'Directory   : %s\n' "$PWD"

    printf 'Git         : '
    dev_git

    printf 'Python      : '
    dev_python

    printf 'Node.js     : '
    dev_node

    printf 'Go          : '
    dev_go

    printf 'Rust        : '
    dev_rust

    printf 'Java        : '
    dev_java
}
