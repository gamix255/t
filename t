#!/usr/bin/env bash
set -u
file="$HOME/.todo"
backupdir="$HOME/.bak"

normal=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

lotate() {
    mkdir -p $backupdir   
    touch $backupdir/`basename $file`.3
    touch $backupdir/`basename $file`.2
    touch $backupdir/`basename $file`.1
    touch $backupdir/`basename $file`.0
    mv $backupdir/`basename $file`.2 $backupdir/`basename $file`.3 
    mv $backupdir/`basename $file`.1 $backupdir/`basename $file`.2 
    mv $backupdir/`basename $file`.0 $backupdir/`basename $file`.1 
    cp $file $backupdir/`basename $file`.0 
}

info () {
    printf "%b" "[${green}$1${normal}] $2 \n"
}

argument_expected() {
    fail "$1 expected an argument"
}

list() {
    ((i=1))
    local done=""
    while read -r line
    do
        if [[ $line = "----------" ]]; then
            done="true"
            break
        fi

        if [[ ! "$done" ]]; then
            echo "[$i] $line"
            ((i++))
        fi
    done < ~/.todo

    echo "----------"

    if [[ $done = "true" ]]; then
        echo "$(sed -n '1!G;h;$p' ~/.todo)" > ~/.todo-tmp
        ((i=0))
        while read -r line
        do

            if [[ $line = "----------" ]]; then
                break
            fi

            if [ $i -lt 5 ]; then
                echo "✅  $line"
            fi
            ((i++))
        done < ~/.todo-tmp

        rm ~/.todo-tmp
    fi

}

add() {
    echo -e "$1\n$(cat ~/.todo)" > ~/.todo
    info "Added" "$1"
}

check() {
    item="$(sed "$1q;d" ~/.todo)"
    echo "$(sed "$1d" ~/.todo)" > ~/.todo
    if grep -q '\----------' ~/.todo; then
        echo "$item" >> ~/.todo
    else
        echo "----------" >> ~/.todo
        echo "$item" >> ~/.todo
    fi
    info "Completed" "$item"
}

check_args() {
    while [ $# -gt 1 ]; do
        local arg="$1"
        case "$1" in
            add|a)
                shift

                if [ -z "$1" ] || [[ "$1" == -* ]]; then
                    argument_expected "$arg"
                fi

                add "$1"

                shift
                ;;
            complete|x)
                shift

                if [ -z "$1" ] || [[ "$1" == -* ]]; then
                    argument_expected "$arg"
                fi
                check "$1"

                shift
                ;;
            *)
                info "Error" "Unknown option $1"
                shift
                ;;
        esac
    done

    exit 0
}

main() {
    lotate 
    touch ~/.todo

    if [ $# -eq 0 ]; then
        list
    fi

    check_args "$@"
}

main "$@"
