#!/bin/bash

. functions.sh
. dirs.sh

recreateDir $PACKAGEDIR

mkdir -p $PACKAGEDIR/bin
cp $LDC_BUILD/bin/ldc2 $PACKAGEDIR/bin/
cp $LDC_BUILD/bin/ldmd2 $PACKAGEDIR/bin/
if [ -e /usr/lib/libconfig++.so.8 ]
then
    cp /usr/lib/libconfig++.so.8 $PACKAGEDIR/bin/libconfig++.so.8
else
    echo Error: /usr/lib/libconfig++.so.8 does not exist. Package will not be self-contained.
fi
cp ldc2.conf $PACKAGEDIR/bin/

mkdir -p $PACKAGEDIR/lib
cp $LDC_BUILD/lib/liblphobos2.a $PACKAGEDIR/lib

mkdir -p $PACKAGEDIR/import
cp -r $DRUNTIME_SOURCE/import/* $PACKAGEDIR/import/
cp -r $PHOBOS_SOURCE/etc $PACKAGEDIR/import/
cp -r $PHOBOS_SOURCE/std $PACKAGEDIR/import/
cp -r $LDC_BUILD/import/* $PACKAGEDIR/import/

cp $LLVM_SOURCE/LICENSE.TXT $PACKAGEDIR/LICENSE_LLVM
cp $LDC_SOURCE/LICENSE $PACKAGEDIR/LICENSE_LDC
cp $DRUNTIME_SOURCE/LICENSE_1_0.txt $PACKAGEDIR/LICENSE_DRUNTIME
cp $PHOBOS_SOURCE/LICENSE_1_0.txt $PACKAGEDIR/LICENSE_PHOBOS
if [ -e /usr/share/doc/libconfig++8-dev/copyright ]
then
    cp /usr/share/doc/libconfig++8-dev/copyright $PACKAGEDIR/LICENSE_LIBCONFIG 
else
    echo Error: /usr/share/doc/libconfig++8-dev/copyright does not exist. Package will miss libconfig license.
fi

echo The package is in the $PACKAGEDIR/ subdirectory. Rename it and create a tarball!
