#!/usr/bin/env bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf dub
git clone --recursive https://github.com/dlang/dub.git
cd dub
git checkout $DUB_VERSION

PATH=$PKG_DIR/bin:$PATH

./build.sh

cp bin/dub $PKG_DIR/bin

