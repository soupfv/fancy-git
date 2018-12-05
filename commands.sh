#!/bin/bash

. ~/.fancy-git/version.sh

fg_script_help() {
    sh ~/.fancy-git/help.sh | less
}

fg_show_version() {
    local current_year
    current_year=$(date +%Y)
    echo " Fancy Git v$FANCYGIT_VERSION (c) $current_year by Diogo Alexsander Cavilha <diogocavilha@gmail.com>."
    echo ""
}

fg_update() {
    local current_dir
    local mode_file
    local base_path

    base_path="/home/$USER/.fancy-git"

    if [ ! -d "$base_path" ]; then
        styles_dir="/Users/$USER/.fancy-git"
    fi

    current_dir=$(pwd)
    mode_file="$base_path/mode"

    cd ~/.fancy-git/ && git pull origin update-checker

    if [ ! -f "$mode_file" ]; then
        touch -f "$mode_file"
        echo "default" > "$mode_file"
    fi

    cd "$current_dir" || return
    head -n 20 ~/.fancy-git/CHANGELOG.md
}

fg_command_not_found() {
    echo ""
    echo " $1: Command not found."
    fg_script_help
}

fg_change_mode() {
    echo "$1" > ~/.fancy-git/mode
    echo ""
    echo " If you cannot see any changes yet, please restart the terminal session."
    echo ""
}

fg_install_fonts() {
    mkdir ~/.fonts
    cp -i ~/.fancy-git/fonts/SourceCodePro+Powerline+Awesome+Regular.ttf ~/.fonts
    fc-cache -fv
}

fg_update_checker() {
    local updates
    local option
    local branch_name
    local manual_update

    manual_update=${1:-yes} # yes, no

    if [ "$manual_update" = "yes" ]
    then
        fg_update
        return
    fi

    branch_name=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ "$branch_name" = "" ]
    then
        return
    fi

    cd ~/.fancy-git && git fetch origin 2> /dev/null
    updates=$(cd ~/.fancy-git && git diff origin/update-checker)
    option="n"

    if [ "$updates" != "" ]
    then
        echo ""
        echo " Hey! A new Fancy Git update has been released!"
        read -p " Would you like to update it? [Y/n]: " option
    fi

    if [ "$option" = "y" ]
    then
        echo ""
        fg_update
    fi
}

case $1 in
    "-h"|"--help") fg_script_help;;
    "-v"|"--version") fg_show_version;;
    "update") fg_update_checker;;
    "simple") fg_change_mode "simple";;
    "default") fg_change_mode "default";;
    "double-line") fg_change_mode "fancy-double-line";;
    "simple-double-line") fg_change_mode "simple-double-line";;
    "human") fg_change_mode "human";;
    "dark") fg_change_mode "dark";;
    "dark-double-line") fg_change_mode "dark-double-line";;
    "light") fg_change_mode "light";;
    "light-double-line") fg_change_mode "light-double-line";;
    "configure-fonts") fg_install_fonts;;
    "") return;;
    *) fg_command_not_found "$1";;
esac
