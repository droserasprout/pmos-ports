#!/bin/sh
# dumpsys.sh
DIR="/sys/devices"

walk() {
    for file in $(ls $1); do
        path="$1/$file"
        if test -L "$path"; then
            continue
        fi
        if test -f "$path"; then
            echo "$path"
            cat "$path"
        fi
        if test -d "$path"; then
            walk "$path"
        fi
    done
}

others() {
    cat /proc/cpuinfo
    cat /proc/cmdline
}

walk "$DIR"
others