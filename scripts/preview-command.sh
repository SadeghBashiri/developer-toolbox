#!/usr/bin/env bash

TOOLBOX_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "$TOOLBOX_DIR/lib/parser.sh"

file="$1"

if [[ -z "$file" || ! -f "$file" ]]; then
    echo "Preview unavailable."
    exit 1
fi

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
        print "  " value
        print

        next
    }

    /^DESCRIPTION:/ {
        value = $0
        sub(/^DESCRIPTION:[[:space:]]*/, "", value)

        print "DESCRIPTION:"
        print "  " value
        print

        next
    }

    /^TAGS:/ {
        value = $0
        sub(/^TAGS:[[:space:]]*/, "", value)

        print "TAGS:"
        print "  " value
        print

        next
    }

    /^COMMAND:/ {
        found = 1

        print "COMMAND:"
        print

        next
    }

    found && NF {
        print "  " $0
    }
' "$file"

echo
echo "PARAMETERS:"
echo

parameters=$(get_parameters "$file")

if [[ -z "$parameters" ]]; then

    echo "  None"

else

    while IFS=$'\t' read -r parameter default_value; do

        echo "  $parameter"

        if [[ -n "$default_value" ]]; then
            echo "    Default: $default_value"
        else
            echo "    Required"
        fi

        echo

    done <<< "$parameters"

fi