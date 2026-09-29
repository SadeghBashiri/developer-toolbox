#!/usr/bin/env bash

TOOLBOX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

COMMANDS_DIR="$TOOLBOX_DIR/commands"
SCRIPTS_DIR="$TOOLBOX_DIR/scripts"

DEV_EDITOR="${DEV_EDITOR:-code}"

# --------------------------------------
# fzf
# --------------------------------------

if command -v fzf >/dev/null 2>&1; then

    FZF_COMMAND="fzf"

elif command -v fzf.exe >/dev/null 2>&1; then

    FZF_COMMAND="fzf.exe"

else

    FZF_COMMAND=""

fi