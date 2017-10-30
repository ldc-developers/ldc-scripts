#!/usr/bin/env bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf tools
git clone --recursive https://github.com/dlang/tools.git
cd tools
git checkout master

PATH=$PKG_DIR/bin:$PATH

make -f posix.mak install DMD=$PKG_DIR/bin/ldmd2 INSTALL_DIR=$PWD

cp bin/rdmd bin/ddemangle bin/dustmite $PKG_DIR/bin
