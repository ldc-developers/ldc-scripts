#!/bin/bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

if [[ $LLVM_VERSION == release_* ]]; then
    rm -rf llvm
    svn checkout http://llvm.org/svn/llvm-project/llvm/branches/$LLVM_VERSION llvm
else
    rm -f llvm-$LLVM_VERSION.src.tar.gz
    curl -O http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.gz
    tar xzf llvm-$LLVM_VERSION.src.tar.gz

    rm -rf llvm
    mv llvm-$LLVM_VERSION.src llvm
fi

rm -rf $WORK_DIR/llvm
mkdir -p $WORK_DIR/llvm
cd $WORK_DIR/llvm

if [ "$OS" == "mingw" ]; then
    cmake $CMAKE_GENERATOR $SRC_DIR/llvm/ -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=$INTERMEDIATE_DIR -DCMAKE_BUILD_TYPE=Release
else
    $SRC_DIR/llvm/configure --enable-optimized --disable-assertions \
        --enable-targets=x86 --prefix=$INTERMEDIATE_DIR
fi

$MAKE install
