#!/bin/bash

function removeDir {
    TOREMOVE=
    for D in $*
    do
        if [ -e $1 ]
        then
            TOREMOVE="$TOREMOVE $D"
        fi
    done
    if [ -n "$TOREMOVE" ]
    then
        echo Removing $TOREMOVE
        rm -rfI $TOREMOVE
    fi
}

function recreateDir {
    removeDir $*
    mkdir -p $*
}

function error {
    echo ERROR: $*
    exit 1
}
