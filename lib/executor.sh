#!/usr/bin/env bash

execute_command() {

    local command="$1"

    echo
    echo "Executing..."
    echo

    eval "$command"

    return $?

}

execute_with_confirmation() {

    local command="$1"
    local answer

    # --------------------------------------
    # Dangerous Command Detection
    # --------------------------------------

    if is_dangerous_command "$command"; then

        local danger_reason
        local danger_severity

        danger_reason=$(get_danger_reason "$command")
        danger_severity=$(get_danger_severity "$command")

        echo
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "WARNING: Potentially dangerous command"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo
        echo "Severity:"
        echo
        echo "  $danger_severity"
        echo
        echo "Reason:"
        echo
        echo "  $danger_reason"
        echo
        echo "Command:"
        echo
        echo "  $command"
        echo

        read -r -p "Are you sure you want to execute this command? [y/N]: " answer < /dev/tty

    else

        read -r -p "Execute this command? [y/N]: " answer < /dev/tty

    fi

    # --------------------------------------
    # Confirmation
    # --------------------------------------

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then

        echo
        echo "Cancelled."
        return 0

    fi

    # --------------------------------------
    # Execute
    # --------------------------------------

    execute_command "$command"

}

run_command_pipeline() {

    local file="$1"

    # --------------------------------------
    # Parse command
    # --------------------------------------

    local command

    command=$(get_command "$file")

    show_command "$command"

    # --------------------------------------
    # Resolve parameters
    # --------------------------------------

    command=$(resolve_parameters "$command") || return 1

    echo
    echo "Resolved command:"
    echo
    echo "  $command"
    echo

    # --------------------------------------
    # Edit
    # --------------------------------------

    local edit
	local command_edited=false

	read -r -p "Edit command before execution? [y/N]: " edit < /dev/tty

	if [[ "$edit" =~ ^[Yy]$ ]]; then

		local original_command="$command"

		command=$(edit_command "$command")

		echo
		echo "--------------------------------------"
		echo "Modified command:"
		echo
		echo "$command"
		echo "--------------------------------------"
		echo

		if [[ "$command" != "$original_command" ]]; then
			command_edited=true
		fi

	fi

    # --------------------------------------
    # Execute
    # --------------------------------------

    local answer

	# --------------------------------------
	# Save as New Command
	# --------------------------------------

	if [[ "$command_edited" == true ]]; then

		local save_answer

		read -r -p "Save as new command? [y/N]: " save_answer < /dev/tty

		if [[ "$save_answer" =~ ^[Yy]$ ]]; then

			local category

			category=$(get_command_category "$file")

			prompt_save_command "$command" "$category"

		fi

	fi

    # --------------------------------------
	# Execute with Confirmation
	# --------------------------------------

	execute_with_confirmation "$command"

	local exit_code=$?

	record_history "$command" "$exit_code"

	echo
	echo "Exit code: $exit_code"

	return "$exit_code"

}