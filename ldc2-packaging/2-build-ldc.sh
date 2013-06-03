#!/bin/bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf ldc
git clone --recursive http://github.com/ldc-developers/ldc.git
cd ldc && git checkout release-$LDC_VERSION && git submodule update

rm -rf $WORK_DIR/ldc
mkdir -p $WORK_DIR/ldc
cd $WORK_DIR/ldc

extra_flags=
if [ "$OS" == "linux" ]; then
    extra_flags="$extra_flags -DCMAKE_EXE_LINKER_FLAGS='-Wl,-rpath,\$ORIGIN'"
fi
if [ "$OS" == "mingw" ]; then
    # Tailored to the setup described in
    # http://wiki.dlang.org/Building_LDC_on_MinGW_x86.
    # We should add support for starting from a clean MinGW/MSYS installation.
    extra_flags="$extra_flags -DLIBCONFIG++_INCLUDE_DIR=/local/include"
    extra_flags="$extra_flags -DLIBCONFIG++_LIBRARY=/local/lib/libconfig++.dll.a"
fi
if [ -n "$MULTILIB" ]; then
    extra_flags="$extra_flags -DMULTILIB=ON"
fi

cmake $CMAKE_GENERATOR $SRC_DIR/ldc -DCMAKE_INSTALL_PREFIX=$PKG_DIR \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_ROOT_DIR=$INTERMEDIATE_DIR \
    -DINCLUDE_INSTALL_DIR=$BUILD_ROOT/pkg/import $extra_flags
rm -rf $PKG_DIR
$MAKE install

rm $PKG_DIR/etc/ldc2.rebuild.conf
perl -pi -e s,$PKG_DIR/,%%ldcbinarypath%%/../,g $BUILD_ROOT/pkg/etc/ldc2.conf

if [ "$OS" == "osx" ]; then
    libfile=$(otool -L $PKG_DIR/bin/ldc2 | grep libconfig | cut -f1 -d ' ' | xargs)
    cp $libfile $PKG_DIR/bin
    install_name_tool -change $libfile @executable_path/$(basename $libfile) $PKG_DIR/bin/ldc2
elif [ "$OS" == "linux" ]; then
    libfile=$(ldd $PKG_DIR/bin/ldc2 | grep libconfig | cut -d ' ' -f 3)
    cp $libfile $PKG_DIR/bin
fi
