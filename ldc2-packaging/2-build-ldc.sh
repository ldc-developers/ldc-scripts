#!/usr/bin/env bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

rm -rf ldc
if [ -z $LDC_SOURCE ]; then
    git clone --recursive https://github.com/ldc-developers/ldc.git ldc
    cd ldc
    git checkout v$LDC_VERSION$LDC_VERSION_SUFFIX && git submodule update
elif [ -d $LDC_SOURCE -a -d $LDC_SOURCE/.git ]; then
    git clone $LDC_SOURCE ldc
    cd ldc
    cat <<EOF >.gitmodules
[submodule "druntime"]
	path = runtime/druntime
	url = $LDC_SOURCE/runtime/druntime
[submodule "phobos"]
	path = runtime/phobos
	url = $LDC_SOURCE/runtime/phobos
[submodule "tests/d2/dmd-testsuite"]
	path = tests/d2/dmd-testsuite
	url = $LDC_SOURCE/tests/d2/dmd-testsuite
EOF
    git submodule init
    git checkout v$LDC_VERSION$LDC_VERSION_SUFFIX && git submodule update
else
    echo "Environment variable LDC_SOURCE does not point to git folder"
    exit 1
fi

extra_flags=()
if [ "$OS" == "linux" ]; then
    # We build on Ubuntu 12.04 with a backported gcc 4.9.
    # Therefore we must specify --static-libstdc++ to avoid dynamic link errors
    extra_flags+=("-DCMAKE_EXE_LINKER_FLAGS='-static-libstdc++ -Wl,-rpath,\\\\\$\$ORIGIN'")
fi
if [ "$OS" == "solaris" ]; then
    # We build on OpenSolaris 11.2 with additional installed gcc 4.8.
    # Therefore we must specify --static-libstdc++ to avoid dynamic link errors
    extra_flags+=("-DCMAKE_EXE_LINKER_FLAGS='-static-libstdc++'")
fi
if [ -n "$USE_LIBCPP" ]; then
    # If LLVM was built against libc++, we need to do the same with LDC to be
    # able to link against it.
    if [ "$OS" == "osx" ]; then
        extra_flags+=("-DCMAKE_CXX_FLAGS='-stdlib=libc++'" "-DCMAKE_EXE_LINKER_FLAGS='-lc++'")
    else
        extra_flags+=("-DCMAKE_CXX_FLAGS='-stdlib=libc++'" "-DCMAKE_EXE_LINKER_FLAGS='-stdlib=libc++'")
    fi
fi

# Build bootstrap LDC.

rm -rf $WORK_DIR/ldc-bootstrap
mkdir -p $WORK_DIR/ldc-bootstrap
cd $WORK_DIR/ldc-bootstrap

cmake $CMAKE_GENERATOR $SRC_DIR/ldc -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ROOT_DIR=$INTERMEDIATE_DIR "${extra_flags[@]}"
$MAKE

# Rebuild LDC with bootstrap compiler.

if [ -n "$MULTILIB" ]; then
    extra_flags+=("-DMULTILIB=ON")
fi

rm -rf $WORK_DIR/ldc
mkdir -p $WORK_DIR/ldc
cd $WORK_DIR/ldc

cmake $CMAKE_GENERATOR $SRC_DIR/ldc -DCMAKE_BUILD_TYPE=Release \
    -DD_COMPILER=$WORK_DIR/ldc-bootstrap/bin/ldmd2 \
    -DLDC_BUILD_WITH_LTO=$BUILD_WITH_LTO \
    -DCMAKE_INSTALL_PREFIX=$PKG_DIR -DINCLUDE_INSTALL_DIR=$BUILD_ROOT/pkg/import \
    -DLLVM_ROOT_DIR=$INTERMEDIATE_DIR "${extra_flags[@]}"
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
