#!/usr/bin/env bash

. env.sh

# Add auxillary files.
if [ "$OS" == "mingw" ]; then
    cp pkgfiles/README.txt $PKG_DIR
else
    cp pkgfiles/README $PKG_DIR
fi

cp $SRC_DIR/ldc/LICENSE $PKG_DIR

# Add Dub settings file to package
cp -r pkgfiles/dub $PKG_DIR/etc

# Rename pkg/ to the final name and zip it up.
cd $BUILD_ROOT
rm -rf $PKG_BASE
mv $PKG_DIR $PKG_BASE

if [ "$OS" == "mingw" ]; then
    rm -f $PKG_BASE.zip $PKG_BASE.7z
    zip -9 -r $PKG_BASE.zip $PKG_BASE
    7z a -t7z $PKG_BASE.7z $PKG_BASE -mx9
else
    rm -f $PKG_BASE.tar.gz $PKG_BASE.tar.xz
    $TAR czvf $PKG_BASE.tar.gz $PKG_BASE
    $TAR cvf $PKG_BASE.tar $PKG_BASE
    xz -z -e -9 $PKG_BASE.tar
fi

# Create source archive.
cd $SRC_DIR
rm -f ../ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz
$TAR czf ../ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz --exclude-vcs --transform=s/ldc/ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src/ ldc
