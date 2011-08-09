#!/bin/bash

. functions.sh
. dirs.sh

removeDir $DRUNTIME_SOURCE
removeDir $PHOBOS_SOURCE
removeDir $LDC_BUILD/import $LDC_BUILD/lib $LDC_BUILD/runtime

if [ ! -e $DRUNTIME_SOURCE ]
then
    git clone git://github.com/ldc-developers/druntime.git $DRUNTIME_SOURCE
fi

if [ ! -e $PHOBOS_SOURCE ]
then
    git clone git://github.com/ldc-developers/phobos.git $PHOBOS_SOURCE
fi

cd $LDC_BUILD
# if ! cmake -D D_VERSION=2 -D LLVM_INSTDIR=$LLVM_PREFIX -DRUNTIME_DIR=$DRUNTIME_SOURCE -DPHOBOS2_DIR=$PHOBOS_SOURCE $LDC_SOURCE
if ! cmake -DRUNTIME_DIR=$DRUNTIME_SOURCE -DPHOBOS2_DIR=$PHOBOS_SOURCE $LDC_SOURCE
then
    error Failed to cmake stdlib
fi

if ! make phobos2 
then
    error Failed to build stdlib
fi
