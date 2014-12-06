#!/bin/bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf ldc
git clone --recursive https://github.com/ldc-developers/ldc.git
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
    extra_flags="$extra_flags -DLIBCONFIG_INCLUDE_DIR=/local/include"
    extra_flags="$extra_flags -DLIBCONFIG_LIBRARY=/local/lib/libconfig.dll.a"
fi
if [ -n "$USE_LIBCPP" ]; then
    # If LLVM was built against libc++, we need to do the same with LDC to be
    # able to link against it.
    extra_flags="$extra_flags -DCMAKE_CXX_FLAGS='-stdlib=libc++' \
        -DCMAKE_EXE_LINKER_FLAGS='-stdlib=libc++'"
fi
if [ -n "$MULTILIB" ]; then
    extra_flags="$extra_flags -DMULTILIB=ON"
fi

cmake $CMAKE_GENERATOR $SRC_DIR/ldc -DCMAKE_INSTALL_PREFIX=$PKG_DIR \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_ROOT_DIR=$INTERMEDIATE_DIR \
    -DINCLUDE_INSTALL_DIR=$BUILD_ROOT/pkg/import $extra_flags
rm -rf $PKG_DIR
$MAKE install

if [ "$OS" == "mingw" ]; then
    # Need to expand this to the full Windows path, CMake does as well.
    pkg_replace_dir=$(exec 2>/dev/null; cd "$PKG_DIR" && pwd -W)
else
    pkg_replace_dir=$PKG_DIR
fi
perl -pi -e s?$pkg_replace_dir/?%%ldcbinarypath%%/../?g $PKG_DIR/etc/ldc2.conf

# Perl on MinGW/MSYS creates a backup file despite -i being specified without
# an argument.
rm -f $PKG_DIR/etc/ldc2.conf.bak

if [ "$OS" == "osx" ]; then
    libfile=$(otool -L $PKG_DIR/bin/ldc2 | grep libconfig | cut -f1 -d ' ' | xargs)
    cp $libfile $PKG_DIR/bin
    install_name_tool -change $libfile @executable_path/$(basename $libfile) $PKG_DIR/bin/ldc2
elif [ "$OS" == "linux" ]; then
    libfile=$(ldd $PKG_DIR/bin/ldc2 | grep libconfig | cut -d ' ' -f 3)
    cp $libfile $PKG_DIR/bin
fi
