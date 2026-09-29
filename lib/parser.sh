#!/usr/bin/env bash

get_command() {

    local file="$1"

    awk '
        /^COMMAND:/ {
            found=1
            next
        }

        found && NF {
            print
        }
    ' "$file"

}

get_metadata() {

    local file="$1"

    awk '
        /^NAME:/ {
            name = $0
            sub(/^NAME:[[:space:]]*/, "", name)
        }

        /^DESCRIPTION:/ {
            description = $0
            sub(/^DESCRIPTION:[[:space:]]*/, "", description)
        }

        /^TAGS:/ {
            tags = $0
            sub(/^TAGS:[[:space:]]*/, "", tags)
        }

        END {
            printf "%s | %s | %s\n", name, description, tags
        }
    ' "$file"

}

get_parameters() {

    local file="$1"
    local command

    command=$(get_command "$file")

    while [[ "$command" =~ \{([^}]+)\} ]]; do

        local expression="${BASH_REMATCH[1]}"
        local parameter
        local default_value=""

        if [[ "$expression" == *=* ]]; then

            parameter="${expression%%=*}"
            default_value="${expression#*=}"

        else

            parameter="$expression"

        fi

        printf '%s\t%s\n' \
            "$parameter" \
            "$default_value"

        command="${command/\{$expression\}/}"

    done

}