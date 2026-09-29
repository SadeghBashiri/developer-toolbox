#!/usr/bin/env bash

sync_check_repository() {
    if ! git -C "$TOOLBOX_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Toolbox is not a Git repository."
        return 1
    fi

    return 0
}

sync_check_remote() {
    if ! git -C "$TOOLBOX_DIR" remote get-url origin >/dev/null 2>&1; then
        echo "Error: Git remote 'origin' is not configured."
        return 1
    fi

    return 0
}

sync_check_clean() {
    if [[ -n "$(git -C "$TOOLBOX_DIR" status --porcelain)" ]]; then
        echo
        echo "Local changes detected."
        echo
        git -C "$TOOLBOX_DIR" status --short
        echo
        echo "Sync cancelled."
        echo "Commit or stash your local changes before syncing."
        return 1
    fi

    return 0
}

sync_repository() {
    echo
    echo "======================================"
    echo "        Developer Toolbox Sync"
    echo "======================================"
    echo

    sync_check_repository || return 1
    sync_check_remote || return 1
    sync_check_clean || return 1

    echo "Pulling latest changes..."
    echo

    git -C "$TOOLBOX_DIR" pull --ff-only
    local exit_code=$?

    echo

    if [[ "$exit_code" -eq 0 ]]; then
        echo "Sync completed successfully."
    else
        echo "Sync failed."
        echo
        echo "No automatic merge was performed."
    fi

    return "$exit_code"
}
