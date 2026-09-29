#!/usr/bin/env bash

resolve_parameters() {

    local command="$1"

    while [[ "$command" =~ \{([^}]+)\} ]]; do

        local expression="${BASH_REMATCH[1]}"
        local parameter
        local default_value=""
        local value

        # --------------------------------------
        # Parse parameter expression
        # --------------------------------------

        if [[ "$expression" == *=* ]]; then

            parameter="${expression%%=*}"
            default_value="${expression#*=}"

        else

            parameter="$expression"

        fi

        # --------------------------------------
        # CLI Parameter
        # --------------------------------------

        if [[ -n "${CLI_PARAMETERS[$parameter]+_}" ]]; then

            value="${CLI_PARAMETERS[$parameter]}"

        # --------------------------------------
        # Default Parameter
        # --------------------------------------

        elif [[ -n "$default_value" ]]; then

            read -r -p \
                "Enter value for '$parameter' [$default_value]: " \
                value < /dev/tty

            if [[ -z "$value" ]]; then
                value="$default_value"
            fi

        # --------------------------------------
        # Required Parameter
        # --------------------------------------

        else

            read -r -p \
                "Enter value for '$parameter': " \
                value < /dev/tty

            if [[ -z "$value" ]]; then

                echo >&2
                echo "Parameter '$parameter' cannot be empty." >&2

                return 1

            fi

        fi

        # --------------------------------------
        # Replace parameter
        # --------------------------------------

        command="${command/\{$expression\}/$value}"

    done

    printf '%s\n' "$command"

}

parse_cli_parameters() {

    declare -gA CLI_PARAMETERS=()

    for argument in "$@"; do

        if [[ "$argument" != *=* ]]; then

            echo "Invalid parameter: $argument" >&2
            echo "Expected format: name=value" >&2

            return 1

        fi

        local name="${argument%%=*}"
        local value="${argument#*=}"

        if [[ -z "$name" ]]; then

            echo "Parameter name cannot be empty." >&2
            return 1

        fi

        CLI_PARAMETERS["$name"]="$value"

    done

}

validate_cli_parameters() {

    local file="$1"

    # --------------------------------------
    # Collect defined parameters
    # --------------------------------------

    declare -A DEFINED_PARAMETERS=()

    while IFS=$'\t' read -r parameter default_value; do

        if [[ -n "$parameter" ]]; then
            DEFINED_PARAMETERS["$parameter"]=1
        fi

    done < <(get_parameters "$file")

    # --------------------------------------
    # Validate CLI parameters
    # --------------------------------------

    for parameter in "${!CLI_PARAMETERS[@]}"; do

        if [[ -z "${DEFINED_PARAMETERS[$parameter]+_}" ]]; then

            echo >&2
            echo "Unknown parameter: $parameter" >&2
            echo >&2

            return 1

        fi

    done

    return 0

}