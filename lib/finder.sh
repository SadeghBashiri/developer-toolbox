#!/usr/bin/env bash

find_commands() {

    find "$COMMANDS_DIR" \
        -type f \
        -name "*.md" \
        | sed "s|$COMMANDS_DIR/||"

}

list_commands() {

    local commands

    commands=$(find_commands)

    if [[ -z "$commands" ]]; then
        echo "No commands found."
        return 1
    fi

    printf '%s\n' "$commands"

}

search_commands() {

    local search_term="$1"

    find "$COMMANDS_DIR" \
        -type f \
        -name "*.md" \
        -print0 |
        xargs -0 grep -il "$search_term" |
        sed "s|$COMMANDS_DIR/||"

}

select_search_command() {

    local search_term="$1"
    local commands

    commands=$(search_commands "$search_term")

    if [[ -z "$commands" ]]; then
        echo "No commands found."
        return 1
    fi

    build_command_list "$commands" |
        "$FZF_COMMAND" \
            --height=70% \
            --border \
            --prompt="Search > " \
            --delimiter=$'\t' \
            --with-nth=1,2 \
            --preview="$TOOLBOX_DIR/scripts/preview-command.sh {3}" \
            --preview-window=right:50% |
        cut -f1

}

build_command_list() {

    local commands="$1"
    local commands_dir="$COMMANDS_DIR"

    while IFS= read -r file; do

        local metadata
        local full_path

        full_path="$commands_dir/$file"
        metadata=$(get_metadata "$full_path")

        printf '%s\t%s\t%s\n' \
            "$file" \
            "$metadata" \
            "$full_path"

    done <<< "$commands"

}

select_command() {

    local commands

    commands=$(find_commands)

    if [[ -z "$commands" ]]; then
        echo "No commands found."
        return 1
    fi

    build_command_list "$commands" |
        "$FZF_COMMAND" \
            --height=70% \
            --border \
            --prompt="Command > " \
            --delimiter=$'\t' \
            --with-nth=1,2 \
            --preview="$TOOLBOX_DIR/scripts/preview-command.sh {3}" \
            --preview-window=right:50% |
        cut -f1

}

show_command_preview() {

    local file="$1"

    echo
    echo "======================================"
    echo "Command Information"
    echo "======================================"
    echo

    awk '
        /^NAME:/ {
            value = $0
            sub(/^NAME:[[:space:]]*/, "", value)
            print "NAME:"
            print value
            print
        }

        /^DESCRIPTION:/ {
            value = $0
            sub(/^DESCRIPTION:[[:space:]]*/, "", value)
            print "DESCRIPTION:"
            print value
            print
        }

        /^TAGS:/ {
            value = $0
            sub(/^TAGS:[[:space:]]*/, "", value)
            print "TAGS:"
            print value
            print
        }
    ' "$file"

    echo "COMMAND:"
    echo

    get_command "$file"

}

list_category_commands() {

    local category="$1"
    local directory="$COMMANDS_DIR/$category"

    if [[ ! -d "$directory" ]]; then

        echo "Category not found: $category"
        return 1

    fi

    find "$directory" \
        -type f \
        -name "*.md" \
        | sed "s|$COMMANDS_DIR/||"

}

find_command_file() {

    local command_name="$1"

    local file

    file="$COMMANDS_DIR/$command_name"

    if [[ -f "$file" ]]; then
        printf '%s\n' "$file"
        return 0
    fi

    if [[ -f "$file.md" ]]; then
        printf '%s\n' "$file.md"
        return 0
    fi

    return 1

}