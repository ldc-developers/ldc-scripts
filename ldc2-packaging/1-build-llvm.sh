#!/usr/bin/env bash

. env.sh
set -x

mkdir -p $SRC_DIR
cd $SRC_DIR
rm -rf llvm

if [[ $LLVM_VERSION == /* ]]; then
    if [ "${LLVM_VERSION##*.}" == "gz" ]; then
        $TAR xzf $LLVM_VERSION
    else
        $TAR xJf $LLVM_VERSION
    fi
    base=$(basename $LLVM_VERSION)
    mv "${base%.*.*}" llvm
elif [[ $LLVM_VERSION == release_* ]]; then
    svn checkout http://llvm.org/svn/llvm-project/llvm/branches/$LLVM_VERSION llvm
    svn checkout http://llvm.org/svn/llvm-project/lld/branches/$LLVM_VERSION llvm/tools/lld
elif [[ $LLVM_VERSION == rev_* ]]; then
    LLVM_REV=${LLVM_VERSION:4}
    svn checkout http://llvm.org/svn/llvm-project/llvm/trunk@$LLVM_REV llvm
    svn checkout http://llvm.org/svn/llvm-project/lld/trunk@$LLVM_REV llvm/tools/lld
else
    rm -f llvm-$LLVM_VERSION.src.tar.xz
    curl -OL "https://github.com/ldc-developers/llvm/releases/download/ldc-v$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz"
    $TAR xJf llvm-$LLVM_VERSION.src.tar.xz
    rm -f llvm-$LLVM_VERSION.src.tar.xz
    mv llvm-$LLVM_VERSION.src llvm
fi

rm -rf $WORK_DIR/llvm
mkdir -p $WORK_DIR/llvm
cd $WORK_DIR/llvm

if [ "$OS" == "mingw" ]; then
    cmake $CMAKE_GENERATOR $SRC_DIR/llvm/ -DLLVM_TARGETS_TO_BUILD=X86 \
        -DCMAKE_INSTALL_PREFIX=$INTERMEDIATE_DIR -DCMAKE_BUILD_TYPE=Release
elif [ -n "$LLVM_USE_CMAKE" ]; then
    # LLVM >= 3.9 no longer supports building with configure & make.
    extra_flags=
    if [ -n "$USE_LIBCPP" ]; then
        extra_flags="$extra_flags -DLLVM_ENABLE_LIBCXX=True"
    fi
    if [ "$OS" == "linux" ]; then
        # Link against static libstdc++ to avoid dynamic link errors with
        # incompatible system versions, e.g., for the LLVMgold.so plugin.
        extra_flags="$extra_flags -DLLVM_BINUTILS_INCDIR=/usr/include -DCMAKE_CXX_FLAGS=-static-libstdc++"
    fi
    if [ "$OS" == "solaris" ]; then
        extra_flags="$extra_flags -DPYTHON_EXECUTABLE=/usr/bin/python3.4"
    fi

    # Choose set of enabled LLVM targets based on host architecture
    case "$ARCH" in
        aarch64) llvm_targets="AArch64;ARM" ;;
        arm) llvm_targets="ARM" ;;
        x86) llvm_targets="X86" ;;
        x86_64) llvm_targets="X86;AArch64;ARM;PowerPC;NVPTX" ;;
    esac

    cmake $CMAKE_GENERATOR $SRC_DIR/llvm/ -DLLVM_TARGETS_TO_BUILD=$llvm_targets \
        -DCMAKE_INSTALL_PREFIX=$INTERMEDIATE_DIR -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_LTO=$BUILD_WITH_LTO $extra_flags
else
    extra_flags=
    if [ -n "$USE_LIBCPP" ]; then
        extra_flags="$extra_flags --enable-libcpp"
    fi
    if [ "$OS" == "solaris" ]; then
        extra_flags="$extra_flags --with-python=/usr/bin/python3.4"
    fi
    $SRC_DIR/llvm/configure --enable-optimized --disable-assertions \
        --enable-targets=$ARCH --prefix=$INTERMEDIATE_DIR $extra_flags
fi

$MAKE install

# Clean up build area for smaller Docker image.
rm -rf $WORK_DIR/llvm
