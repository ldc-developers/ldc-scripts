#!/usr/bin/env bash

. env.sh

if [ "$OS" == "mingw" ]; then
	cp pkgfiles/README.txt $PKG_DIR
else
	cp pkgfiles/README $PKG_DIR
fi

cp $SRC_DIR/ldc/LICENSE $PKG_DIR

if [ "$OS" == "mingw" ]; then
    cp /local/bin/libconfig-9.dll $PKG_DIR/bin
fi

cd $BUILD_ROOT
rm -rf $PKG_BASE
mv $PKG_DIR $PKG_BASE

if [ "$OS" == "mingw" ]; then
    rm -f $PKG_BASE.zip $PKG_BASE.7z
    zip -9 -r $PKG_BASE.zip $PKG_BASE
    7z a -t7z $PKG_BASE.7z $PKG_BASE -mx9
else
    rm -f $PKG_BASE.tar.gz $PKG_BASE.tar.xz
    tar czvf $PKG_BASE.tar.gz $PKG_BASE
    tar cvf $PKG_BASE.tar $PKG_BASE
    xz -z -e -9 $PKG_BASE.tar
fi

cd $SRC_DIR
rm -f ../ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz
tar czf ../ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz --exclude-vcs --transform=s/ldc/ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src/ ldc
