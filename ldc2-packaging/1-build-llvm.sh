#!/bin/bash

. functions.sh
. dirs.sh

removeDir $LLVM_SOURCE
recreateDir $LLVM_BUILD $LLVM_PREFIX

LLVM_VERSION=2.9
LLVM_SOURCE_PACKAGE=http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.tgz
if [ ! -e $WORKDIR/llvm-source.tgz ]
then
    wget $LLVM_SOURCE_PACKAGE -O $WORKDIR/llvm-source.tgz
fi
if [ ! -e $WORKDIR/llvm-source.tgz ]
then
    error Failed to fetch LLVM sources from $LLVM_SOURCE_PACKAGE
fi
if [ ! -e $LLVM_SOURCE ]
then
    tar -xzf $WORKDIR/llvm-source.tgz
    mv llvm-$LLVM_VERSION $LLVM_SOURCE
fi

cd $LLVM_BUILD
if ! $LLVM_SOURCE/configure --prefix=$LLVM_PREFIX --enable-optimized --enable-targets=x86
then
    error Failed to configure LLVM
fi
if ! make
then
    error Failed to build LLVM
fi
if ! make install
then
    error Failed to install LLVM
fi
