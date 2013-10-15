#!/bin/bash

. env.sh

if [ "$OS" == "mingw" ]; then
	cp pkgfiles/README.txt $PKG_DIR
else
	cp pkgfiles/README $PKG_DIR
fi

cp $SRC_DIR/ldc/LICENSE $PKG_DIR

if [ "$OS" == "mingw" ]; then
    cp /local/bin/libconfig++-9.dll $PKG_DIR/bin
fi

cd $BUILD_ROOT
mv $PKG_DIR $PKG_BASE

if [ "$OS" == "mingw" ]; then
    zip -9 -r $PKG_BASE.zip $PKG_BASE
    7z a -t7z $PKG_BASE.7z $PKG_BASE -mx9
else
    tar czvf $PKG_BASE.tar.gz $PKG_BASE
    tar cvf $PKG_BASE.tar $PKG_BASE
    xz -z -e -9 $PKG_BASE.tar
fi
