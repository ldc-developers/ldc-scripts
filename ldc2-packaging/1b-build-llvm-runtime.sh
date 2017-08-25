#!/usr/bin/env bash

# Builds compiler-rt and libFuzzer and puts them in the LLVM install dir

. env.sh
set -x

mkdir -p $SRC_DIR
cd $SRC_DIR
rm -rf compiler-rt

#if [[ $LLVM_VERSION == /* ]]; then
#    if [ "${LLVM_VERSION##*.}" == "gz" ]; then
#        $TAR xzf $LLVM_VERSION
#    else
#        $TAR xJf $LLVM_VERSION
#    fi
#    base=$(basename $LLVM_VERSION)
#    mv "${base%.*.*}" llvm
#elif [[ $LLVM_VERSION == release_* ]]; then
#    svn checkout http://llvm.org/svn/llvm-project/llvm/branches/$LLVM_VERSION llvm
#    svn checkout http://llvm.org/svn/llvm-project/lld/branches/$LLVM_VERSION llvm/tools/lld
#elif [[ $LLVM_VERSION == rev_* ]]; then
#    LLVM_REV=${LLVM_VERSION:4}
#    svn checkout http://llvm.org/svn/llvm-project/llvm/trunk@$LLVM_REV llvm
#    svn checkout http://llvm.org/svn/llvm-project/lld/trunk@$LLVM_REV llvm/tools/lld
#else
    rm -f compiler-rt-$LLVM_VERSION.src.tar.xz
    curl -OL "http://releases.llvm.org/$LLVM_VERSION/compiler-rt-$LLVM_VERSION.src.tar.xz"
    $TAR xJf compiler-rt-$LLVM_VERSION.src.tar.xz
    rm -f compiler-rt-$LLVM_VERSION.src.tar.xz
    mv compiler-rt-$LLVM_VERSION.src compiler-rt
#fi

rm -rf $WORK_DIR/compiler-rt
mkdir -p $WORK_DIR/compiler-rt
cd $WORK_DIR/compiler-rt

cmake $CMAKE_GENERATOR $SRC_DIR/compiler-rt/ \
    -DCMAKE_INSTALL_PREFIX=$INTERMEDIATE_DIR/lib/clang/$LLVM_VERSION -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_CONFIG_PATH=$INTERMEDIATE_DIR/bin/llvm-config

$MAKE install

# Clean up build area for smaller Docker image.
rm -rf $WORK_DIR/compiler-rt

# Now that compiler-rt header files are installed into LLVM's installation, we can build libFuzzer
# libFuzzer resides in LLVM's ./lib/Fuzzer dir for versions 4.0 and 5.0, but is moved to compiler-rt in version 6.0
cd $SRC_DIR
cd llvm*
cd lib/Fuzzer
# LLVM's 4.0 lib/Fuzzer/build.sh assumes clang, so we can't use it. Fixed in LLVM 5.0. Build manually for now.
CXX="${CXX:-g++}"
extra_flags=
if [ -n "$USE_LIBCPP" ]; then
    # Needed on OSX
    extra_flags="$extra_flags -stdlib=libc++"
fi
for f in ./*.cpp; do
  $CXX -I $INTERMEDIATE_DIR/lib/clang/$LLVM_VERSION/include -g -O2 -fno-omit-frame-pointer -std=c++11 $f -c $extra_flags &
done
wait
rm -f libFuzzer.a
ar ru libFuzzer.a Fuzzer*.o
rm -f Fuzzer*.o
cp libFuzzer.a $INTERMEDIATE_DIR/lib
