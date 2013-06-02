#!/bin/bash

. env.sh

cp $SRC_DIR/ldc/LICENSE $PKG_DIR

cd $BUILD_ROOT
mv $PKG_DIR $PKG_BASE
tar czvf $PKG_BASE.tar.gz $PKG_BASE
tar cvf $PKG_BASE.tar $PKG_BASE
xz -z -e -9 $PKG_BASE.tar
