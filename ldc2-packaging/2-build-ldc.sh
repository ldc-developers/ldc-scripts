#!/bin/bash

. functions.sh
. dirs.sh

removeDir $LDC_SOURCE
recreateDir $LDC_BUILD

if [ ! -e $LDC_SOURCE ]
then
    hg clone https://bitbucket.org/lindquist/ldc $LDC_SOURCE
fi

cd $LDC_BUILD
if ! cmake -D D_VERSION=2 -D LLVM_INSTDIR=$LLVM_PREFIX -D CMAKE_BUILD_TYPE=Release -D D_FLAGS="-O;-release;-d;-w" -D CMAKE_EXE_LINKER_FLAGS='-Wl,-rpath,\$ORIGIN' $LDC_SOURCE 
then
    error Failed to cmake LDC
fi
if ! make
then
    error Failed to build LDC
fi
cp -p $LDC_SOURCE/bin/ldmd2 bin
