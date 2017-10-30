#!/usr/bin/env bash

. env-ldc.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf dub
git clone --recursive https://github.com/dlang/dub.git
cd dub
git checkout $DUB_VERSION

PATH=$PKG_DIR/bin:$PATH

if [ "$BUILD_WITH_LTO" == "off" ]; then
  export DMD="$PKG_DIR/bin/ldmd2"
else
  export DMD="$PKG_DIR/bin/ldmd2 -flto=$BUILD_WITH_LTO"
fi

./build.sh

cp bin/dub $PKG_DIR/bin

