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

# OS is set in the MSYS shell by default.
if [ "$OS" == "Windows_NT" ]; then
    export OS=mingw
    echo "Auto-detected OS, building for '${OS}'."
    echo
fi

if [ -z "$OS" ]; then
    case "$(uname -s 2>&1)" in
        Linux) export OS=linux ;;
        Darwin) export OS=osx ;;
        *) echo 'Could not auto-detect operating system, set the OS environment variable.' ;;
    esac
    echo "Auto-detected OS, building for '${OS}'."
    echo
fi

if [ -z "$ARCH" ]; then
    case "$(uname -m 2>&1)" in
        i686) export ARCH=x86 ;;
        x86_64) export ARCH=x86_64 ;;
        *) echo 'Could not auto-detect architecture, set the ARCH environment variable.' ;;
    esac
    echo "Auto-detected ARCH, building for '${ARCH}'."
    echo
fi

case "$OS" in
    linux)
        export CMAKE_GENERATOR=
        export MAKE=make
        ;;
    osx)
        export CMAKE_GENERATOR=
        export MAKE=make
        ;;
    mingw)
        export CMAKE_GENERATOR='-G Ninja'
        export MAKE=ninja
        ;;
    *)
        echo "Invalid target operating system (\$OS must be one of linux/osx/mingw)."
        exit 1
        ;;
esac

case "$ARCH" in
    x86) ;;
    x86_64) export MULTILIB=true ;;
    *)
        echo "Invalid target architecture (\$ARCH must be one of x86/x86_64)."
        exit 1
        ;;
esac

if [ -z "$LLVM_VERSION" ]; then
    echo "Set LLVM_VERSION to the LLVM version to use (e.g. '3.2', or 'release_33' to fetch from SVN)."
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

export PKG_BASE=ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$OS-$ARCH

set -ex
