#!/bin/bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

if [[ $LLVM_VERSION == /* ]]; then
    if [ "${LLVM_VERSION##*.}" == "gz" ]; then
        tar xzf $LLVM_VERSION
    else
        tar xJf $LLVM_VERSION
    fi
    base=$(basename $LLVM_VERSION)

    rm -rf llvm
    mv "${base%.*.*}" llvm
elif [[ $LLVM_VERSION == release_* ]]; then
    rm -rf llvm
    svn checkout http://llvm.org/svn/llvm-project/llvm/branches/$LLVM_VERSION llvm
else
    rm -f llvm-$LLVM_VERSION.src.tar.gz llvm-$LLVM_VERSION.src.tar.xz
    curl --fail -O "http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.{gz,xz}"
    if [ -e llvm-$LLVM_VERSION.src.tar.gz ]; then
        tar xzf llvm-$LLVM_VERSION.src.tar.gz
    else
        tar xJf llvm-$LLVM_VERSION.src.tar.xz
    fi

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
