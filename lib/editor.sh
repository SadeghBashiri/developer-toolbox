#!/usr/bin/env bash

edit_command() {

    local command="$1"

    local temp_file

    temp_file=$(mktemp)

    printf '%s\n' "$command" > "$temp_file"

    "$DEV_EDITOR" --wait "$temp_file"

    command=$(cat "$temp_file")

    rm -f "$temp_file"

    printf '%s\n' "$command"

}
