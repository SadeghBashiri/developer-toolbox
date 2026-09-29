#!/usr/bin/env bash

doctor_check_command() {
    local name="$1"
    local command="$2"

    if command -v "$command" >/dev/null 2>&1; then
        echo "✓ $name"
        return 0
    fi

    echo "✗ $name"
    return 1
}

doctor_check_fzf() {
    if [[ -n "${FZF_COMMAND:-}" ]]; then
        echo "✓ fzf ($FZF_COMMAND)"
        return 0
    fi

    echo "✗ fzf"
    return 1
}

doctor_check_directory() {
    local name="$1"
    local directory="$2"

    if [[ -d "$directory" ]]; then
        echo "✓ $name"
        return 0
    fi

    echo "✗ $name"
    return 1
}

doctor_check_git_repository() {
    if git -C "$TOOLBOX_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "✓ Git repository"
        return 0
    fi

    echo "✗ Git repository"
    return 1
}

doctor_check_git_remote() {
    if git -C "$TOOLBOX_DIR" remote get-url origin >/dev/null 2>&1; then
        echo "✓ Git remote (origin)"
        return 0
    fi

    echo "✗ Git remote (origin)"
    return 1
}

doctor_check_git_eol() {
    local autocrlf
    local eol

    autocrlf=$(git -C "$TOOLBOX_DIR" config --get core.autocrlf || true)
    eol=$(git -C "$TOOLBOX_DIR" config --get core.eol || true)

    if [[ "$autocrlf" == "false" && "$eol" == "lf" ]]; then
        echo "✓ Git line endings (LF)"
        return 0
    fi

    echo "✗ Git line endings (expected autocrlf=false, eol=lf)"
    return 1
}

doctor() {
    local failed=0

    echo
    echo "======================================"
    echo "       Developer Toolbox Doctor"
    echo "======================================"
    echo

    echo "Dependencies:"
    echo

    doctor_check_command "Bash" bash || failed=1
    doctor_check_command "Git" git || failed=1
    doctor_check_fzf || failed=1

    echo
    echo "Editor:"
    echo

    if command -v "$DEV_EDITOR" >/dev/null 2>&1; then
        echo "✓ Editor ($DEV_EDITOR)"
    else
        echo "✗ Editor ($DEV_EDITOR)"
        failed=1
    fi

    echo
    echo "Toolbox:"
    echo

    doctor_check_directory "Commands directory" "$COMMANDS_DIR" || failed=1
    doctor_check_directory "Scripts directory" "$SCRIPTS_DIR" || failed=1

    echo
    echo "Git:"
    echo

    doctor_check_git_repository || failed=1
    doctor_check_git_remote || failed=1
    doctor_check_git_eol || failed=1

    echo

    if [[ "$failed" -eq 0 ]]; then
        echo "Environment is ready."
        echo
        return 0
    fi

    echo "Environment has one or more issues."
    echo
    return 1
}
