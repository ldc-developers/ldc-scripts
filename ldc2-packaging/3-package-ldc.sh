#!/bin/bash

. env.sh

cp $SRC_DIR/ldc/LICENSE $PKG_DIR

base=ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$OS-$ARCH

cd $BUILD_ROOT
mv $PKG_DIR $base
tar czvf $base.tar.gz $base
tar cvf $base.tar $base
xz -z -e -9 $base.tar
