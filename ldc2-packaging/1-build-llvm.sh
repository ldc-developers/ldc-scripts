#!/usr/bin/env bash

. env.sh

mkdir -p $SRC_DIR
cd $SRC_DIR

if [[ $LLVM_VERSION == /* ]]; then
    if [ "${LLVM_VERSION##*.}" == "gz" ]; then
        $TAR xzf $LLVM_VERSION
    else
        $TAR xJf $LLVM_VERSION
    fi
    base=$(basename $LLVM_VERSION)

    rm -rf llvm
    mv "${base%.*.*}" llvm
elif [[ $LLVM_VERSION == release_* ]]; then
    rm -rf llvm
    svn checkout http://llvm.org/svn/llvm-project/llvm/branches/$LLVM_VERSION llvm
elif [[ $LLVM_VERSION == rev_* ]]; then
    LLVM_REV=${LLVM_VERSION:4}
    rm -rf llvm
    svn checkout http://llvm.org/svn/llvm-project/llvm/trunk@$LLVM_REV llvm
else
    rm -f llvm-$LLVM_VERSION.src.tar.gz llvm-$LLVM_VERSION.src.tar.xz
    curl --fail -O "http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.{gz,xz}"
    if [ -e llvm-$LLVM_VERSION.src.tar.gz ]; then
        $TAR xzf llvm-$LLVM_VERSION.src.tar.gz
    else
        $TAR xJf llvm-$LLVM_VERSION.src.tar.xz
    fi

    rm -rf llvm
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
    if [ "$OS" == "solaris" ]; then
        extra_flags="$extra_flags -DPYTHON_EXECUTABLE=/usr/bin/python3.4"
    fi
    # Map Arch to correct LLVM target name (notably x86_64 is not recognized by LLVM)
    case "$ARCH" in
        aarch64) LLVM_TARGET="AArch64" ;;
        arm) LLVM_TARGET="ARM" ;;
        x86) LLVM_TARGET="X86" ;;
        x86_64) LLVM_TARGET="X86" ;;
    esac

    cmake $CMAKE_GENERATOR $SRC_DIR/llvm/ -DLLVM_TARGETS_TO_BUILD=$LLVM_TARGET \
        -DCMAKE_INSTALL_PREFIX=$INTERMEDIATE_DIR -DCMAKE_BUILD_TYPE=Release $extra_flags
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
