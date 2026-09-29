#!/usr/bin/env bash

save_command() {

    local command="$1"
    local name="$2"
    local description="$3"
    local tags="$4"
    local file_name="$5"
    local category="$6"

    local directory
    local file

    directory="$COMMANDS_DIR/$category"
    file="$directory/$file_name.md"

    mkdir -p "$directory"

    if [[ -f "$file" ]]; then

        echo
        echo "Command file already exists:"
        echo
        echo "  $file"
        echo

        local overwrite

        read -r -p "Overwrite existing command? [y/N]: " overwrite < /dev/tty

        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then

            echo
            echo "Save cancelled."
            return 1

        fi

    fi

    cat > "$file" <<EOF
NAME: $name
DESCRIPTION: $description
TAGS: $tags

COMMAND:
$command
EOF

    echo
    echo "Command saved:"
    echo
    echo "  $file"
    echo

}

prompt_save_command() {

    local command="$1"
    local category="$2"

    local name
    local description
    local tags
    local file_name

    echo
    echo "======================================"
    echo "        Save as New Command"
    echo "======================================"
    echo

    read -r -p "Name: " name < /dev/tty

    if [[ -z "$name" ]]; then
        echo
        echo "Name cannot be empty."
        return 1
    fi

    read -r -p "Description: " description < /dev/tty

    read -r -p "Tags: " tags < /dev/tty

    read -r -p "File name: " file_name < /dev/tty

    if [[ -z "$file_name" ]]; then
        echo
        echo "File name cannot be empty."
        return 1
    fi

    save_command \
        "$command" \
        "$name" \
        "$description" \
        "$tags" \
        "$file_name" \
        "$category"

}

validate_name() {

    local value="$1"
    local field="$2"

    # --------------------------------------
    # Empty
    # --------------------------------------

    if [[ -z "$value" ]]; then

        echo
        echo "$field cannot be empty."

        return 1

    fi

    # --------------------------------------
    # Special path names
    # --------------------------------------

    if [[ "$value" == "." || "$value" == ".." ]]; then

        echo
        echo "Invalid $field: $value"

        return 1

    fi

    # --------------------------------------
    # Path separators
    # --------------------------------------

    if [[ "$value" == *"/"* || "$value" == *"\\"* ]]; then

        echo
        echo "$field cannot contain path separators."

        return 1

    fi

    # --------------------------------------
    # Path traversal
    # --------------------------------------

    if [[ "$value" == *".."* ]]; then

        echo
        echo "Invalid $field: $value"

        return 1

    fi

    # --------------------------------------
    # Windows invalid filename characters
    # --------------------------------------

    if [[ "$value" == *":"* ||
          "$value" == *"*" ||
          "$value" == *"?" ||
          "$value" == *'"'* ||
          "$value" == *"<"* ||
          "$value" == *">"* ||
          "$value" == *"|"* ]]; then

        echo
        echo "Invalid characters in $field."

        return 1

    fi

    # --------------------------------------
    # Windows reserved names
    # --------------------------------------

    local upper_value
    upper_value="${value^^}"

    case "$upper_value" in

    CON|PRN|AUX|NUL|COM1|COM2|COM3|COM4|COM5|COM6|COM7|COM8|COM9|LPT1|LPT2|LPT3|LPT4|LPT5|LPT6|LPT7|LPT8|LPT9)

        echo
        echo "Reserved Windows name: $value"

        return 1

        ;;

	esac

    return 0

}

add_command() {

    local category="$1"
    local name="$2"
    local description="$3"
    local tags="$4"
    local file_name="$5"
    local command="$6"

    local directory
    local file

    directory="$COMMANDS_DIR/$category"
    file="$directory/$file_name.md"

    mkdir -p "$directory"

    if [[ -f "$file" ]]; then

        echo
        echo "Command file already exists:"
        echo
        echo "  $file"
        echo

        return 1

    fi

    cat > "$file" <<EOF
NAME: $name
DESCRIPTION: $description
TAGS: $tags

COMMAND:
$command
EOF

    echo
    echo "Command created:"
    echo
    echo "  $file"
    echo

}

show_add_command_preview() {

    local category="$1"
    local name="$2"
    local description="$3"
    local tags="$4"
    local file_name="$5"
    local command="$6"

    echo
    echo "======================================"
    echo "        Command Preview"
    echo "======================================"
    echo

    echo "Category:"
    echo "  $category"
    echo

    echo "Name:"
    echo "  $name"
    echo

    echo "Description:"
    echo "  $description"
    echo

    echo "Tags:"
    echo "  $tags"
    echo

    echo "File:"
    echo "  $file_name.md"
    echo

    echo "Command:"
    echo
    echo "  $command"
    echo

    echo "======================================"
    echo

}

prompt_add_command() {

    local category
    local name
    local description
    local tags
    local file_name
    local command

    echo
    echo "======================================"
    echo "        Add New Command"
    echo "======================================"
    echo

    # --------------------------------------
	# Category
	# --------------------------------------

	category=$(select_or_create_category)

	if [[ -z "$category" ]]; then
		return 1
	fi

	validate_name "$category" "Category" || return 1

    # --------------------------------------
    # Name
    # --------------------------------------

    read -r -p "Name: " name < /dev/tty

    if [[ -z "$name" ]]; then

        echo
        echo "Name cannot be empty."

        return 1

    fi

    # --------------------------------------
    # Description
    # --------------------------------------

    read -r -p "Description: " description < /dev/tty

    # --------------------------------------
    # Tags
    # --------------------------------------

    read -r -p "Tags: " tags < /dev/tty

    # --------------------------------------
    # File name
    # --------------------------------------

    read -r -p "File name: " file_name < /dev/tty

    if [[ -z "$file_name" ]]; then

        echo
        echo "File name cannot be empty."

        return 1

    fi

    # --------------------------------------
    # Command
    # --------------------------------------

    read -r -p "Command: " command < /dev/tty

    if [[ -z "$command" ]]; then

        echo
        echo "Command cannot be empty."

        return 1

    fi

	echo
	read -r -p "Edit command before saving? [y/N]: " edit_answer < /dev/tty

	if [[ "$edit_answer" =~ ^[Yy]$ ]]; then

		command=$(edit_command "$command")

		if [[ -z "$command" ]]; then

			echo
			echo "Command cannot be empty."

			return 1

		fi

	fi

	echo
	# --------------------------------------
	# Preview
	# --------------------------------------

	show_add_command_preview \
		"$category" \
		"$name" \
		"$description" \
		"$tags" \
		"$file_name" \
		"$command"

	local save_answer

	read -r -p "Save this command? [y/N]: " save_answer < /dev/tty

    # --------------------------------------
    # Save
    # --------------------------------------

    add_command \
        "$category" \
        "$name" \
        "$description" \
        "$tags" \
        "$file_name" \
        "$command"

}

select_or_create_category() {

    local categories
    local selected

    categories=$(find "$COMMANDS_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' |
        sort)

    categories=$(printf '%s\n%s\n' \
        "$categories" \
        "+ Create new category")

    selected=$(printf '%s\n' "$categories" |
        "$FZF_COMMAND" \
            --height=50% \
            --border \
            --prompt="Category > ")

    if [[ -z "$selected" ]]; then
        return 1
    fi

    if [[ "$selected" == "+ Create new category" ]]; then

        read -r -p "New category: " selected < /dev/tty

        if [[ -z "$selected" ]]; then

            echo
            echo "Category cannot be empty."

            return 1

        fi

    fi

    printf '%s\n' "$selected"

}