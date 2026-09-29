#!/usr/bin/env bash

HISTORY_DIR="$TOOLBOX_DIR/.developer-toolbox-history"
HISTORY_FILE="$HISTORY_DIR/history.log"

init_history() {

    mkdir -p "$HISTORY_DIR"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        touch "$HISTORY_FILE"
    fi

}

record_history() {

    local command="$1"
    local exit_code="$2"

    init_history

    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf '%s\t%s\t%s\n' \
        "$timestamp" \
        "$exit_code" \
        "$command" >> "$HISTORY_FILE"

}

show_history() {

    init_history

    if [[ ! -s "$HISTORY_FILE" ]]; then
        echo "History is empty."
        return 0
    fi

    tac "$HISTORY_FILE" |
        awk -F '\t' '
        {
            status = ($2 == 0 ? "✓" : "✗")
            print $1 " | " status " | " $3
        }
        ' |
        "$FZF_COMMAND" \
            --height=60% \
            --border \
            --prompt="History > " |
        cut -d '|' -f 3- |
        sed 's/^ //'

}

history_action() {

    local command="$1"

    echo
    echo "--------------------------------------"
    echo
    echo "Selected history entry:"
    echo
    echo "  $command"
    echo
    echo "--------------------------------------"
    echo

    while true; do

        read -r -p "[R] Run  [E] Edit  [C] Cancel: " action < /dev/tty

        case "$action" in

            [Rr])
                return 0
                ;;

            [Ee])
                return 1
                ;;

            [Cc])
                return 2
                ;;

            *)
                echo "Invalid option."
                ;;

        esac

    done

}