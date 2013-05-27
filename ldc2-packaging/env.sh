#!/bin/bash

if [ -z "$BUILD_ROOT" ]; then
    cat <<EOM
Set BUILD_ROOT to the working directory for packaging.

Note: The build scripts will *delete* certain files in that directory!

It is suggested to use /build or a similarly concise path because it might end
up in the package as part of debug info, etc.
EOM
    exit 1
fi

export SRC_DIR=$BUILD_ROOT/src
export INTERMEDIATE_DIR=$BUILD_ROOT/intermediate
export WORK_DIR=$BUILD_ROOT/work
export PKG_DIR=$BUILD_ROOT/pkg

case "$OS" in
    linux) ;;
    osx) ;;
    *)  echo "Set OS to the target operating system (linux/osx)."
        exit 1
        ;;
esac

case "$ARCH" in
    x86) ;;
    x86_64) export MULTILIB=true ;;
    *)  echo "Set ARCH to the target architecture (x86/x86_64)."
        exit 1
        ;;
esac

if [ -z "$LLVM_VERSION" ]; then
    echo "Set LLVM_VERSION to the LLVM version to use (e.g. '3.2')."
    exit 1
fi

if [ -z "$LDC_VERSION" ]; then
    cat <<EOM
Set LDC_VERSION to the LDC version to build (e.g. '0.10.0').

This will be used for determining the branch name to fetch.

Use LDC_VERSION_SUFFIX to specify an additional suffix to append to the
version as it appears in file names (e.g. '-beta1').
EOM
    exit 1
fi

set -ex
