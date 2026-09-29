#!/usr/bin/env bash

SECURITY_PATTERNS=(
    'rm[[:space:]]+-rf'
    'rm[[:space:]]+-r'
    'mkfs'
    'dd[[:space:]].*if='
    'shutdown'
    'reboot'
    'docker[[:space:]]+system[[:space:]]+prune'
    'docker[[:space:]]+rm'
    'docker[[:space:]]+rmi'
)

SECURITY_REASONS=(
    'Recursive force deletion detected.'
    'Recursive deletion detected.'
    'Filesystem formatting command detected.'
    'Low-level disk/data operation detected.'
    'System shutdown command detected.'
    'System reboot command detected.'
    'Docker cleanup command may remove unused resources.'
    'Docker container removal command detected.'
    'Docker image removal command detected.'
)

SECURITY_SEVERITIES=(
    'HIGH'
    'HIGH'
    'CRITICAL'
    'CRITICAL'
    'HIGH'
    'HIGH'
    'HIGH'
    'HIGH'
    'HIGH'
)


is_dangerous_command() {

    local command="$1"
    local i

    for i in "${!SECURITY_PATTERNS[@]}"; do

        if [[ "$command" =~ ${SECURITY_PATTERNS[$i]} ]]; then
            return 0
        fi

    done

    return 1

}


get_danger_reason() {

    local command="$1"
    local i

    for i in "${!SECURITY_PATTERNS[@]}"; do

        if [[ "$command" =~ ${SECURITY_PATTERNS[$i]} ]]; then
            echo "${SECURITY_REASONS[$i]}"
            return 0
        fi

    done

    return 1

}

get_danger_severity() {

    local command="$1"
    local i

    for i in "${!SECURITY_PATTERNS[@]}"; do

        if [[ "$command" =~ ${SECURITY_PATTERNS[$i]} ]]; then
            echo "${SECURITY_SEVERITIES[$i]}"
            return 0
        fi

    done

    return 1

}