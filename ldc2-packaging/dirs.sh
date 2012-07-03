#!/bin/bash

WORKDIR=$PWD/tmp
PACKAGEDIR=$PWD/package

LLVM_SOURCE=$WORKDIR/llvm-source
LLVM_BUILD=$WORKDIR/llvm-build
LLVM_PREFIX=$WORKDIR/llvm-prefix

LDC_SOURCE=$WORKDIR/ldc-source
LDC_BUILD=$WORKDIR/ldc-build

DRUNTIME_SOURCE=$LDC_SOURCE/runtime/druntime
PHOBOS_SOURCE=$LDC_SOURCE/runtime/phobos
