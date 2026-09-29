#!/usr/bin/env bash

show_header() {

    echo
    echo "======================================"
    echo "        Developer Toolbox"
    echo "======================================"
    echo

}

show_selected() {

    local selected="$1"

    echo
    echo "--------------------------------------"
    echo "Selected:"
    echo "$selected"
    echo "--------------------------------------"

}

show_command() {

    local command="$1"

    echo
    echo "--------------------------------------"
    echo
    echo "Command:"
    echo
    echo "  $command"
    echo
    echo "--------------------------------------"
    echo

}

show_help() {

    echo
    echo "Developer Toolbox"
    echo
    echo "Usage:"
    echo
    echo "  dev                         Open command selector"
	echo "  dev run <command>           Run a specific command"
    echo "  dev search <term>           Search commands"
    echo "  dev list                    List all commands"
    echo "  dev category <name>         List commands by category"
	echo "  dev add                     Add a new command"
    echo "  dev history                 Browse command history"
    echo "  dev help                    Show this help"
    echo
    echo "Commands:"
    echo
    echo "  search      Search commands using fzf"
    echo "  list        List all stored commands"
    echo "  category    List commands from a category"
	echo "  add         Add a new command"
    echo "  history     Browse and rerun command history"
    echo "  help        Show CLI help"
    echo
    echo "Examples:"
    echo
    echo "  dev"
    echo "  dev search docker logs"
    echo "  dev list"
    echo "  dev category docker"
    echo "  dev history"
    echo

}
