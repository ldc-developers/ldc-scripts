#!/usr/bin/env bash

set -eo pipefail

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
        FreeBSD) export OS=freebsd ;;
        SunOS) export OS=solaris ;;
        *) echo 'Could not auto-detect operating system, set the OS environment variable.' ;;
    esac
    echo "Auto-detected OS, building for '${OS}'."
    echo
fi

if [ -z "$ARCH" ]; then
    case "$(uname -m 2>&1)" in
        aarch64) export ARCH=aarch64 ;;
        arm*) export ARCH=arm ;;
        i686) export ARCH=x86 ;;
        x86_64) export ARCH=x86_64 ;;
        *) echo 'Could not auto-detect architecture, set the ARCH environment variable.' ;;
    esac
    echo "Auto-detected ARCH, building for '${ARCH}'."
    echo
fi

case "$OS" in
    linux)
        export CMAKE_GENERATOR='-G Ninja'
        export MAKE=ninja
        export TAR=tar
        ;;
    osx)
        export CMAKE_GENERATOR=
        export MAKE=make
        # OS X's own tar is old and does not support --exclude-vcs
        export TAR=gnutar
        # On OS X, force Clang to use the libc++ standard library. LLVM 3.5
        # refuses to be built on OS X 10.8.5 otherwise (with Xcode 5.1.1 being
        # the last supported version there), as libstdc++.so.6 is too old.
        export USE_LIBCPP=true
        # Target OS X 10.7 (which is the minimum version we can support due to
        # TLS) even when building on newer systems.
        export MACOSX_DEPLOYMENT_TARGET=10.8
        ;;
    mingw)
        export CMAKE_GENERATOR='-G Ninja'
        export MAKE=ninja
        export TAR=tar
        ;;
    freebsd)
        export CMAKE_GENERATOR=
        export MAKE=gmake
        export TAR=tar
        ;;
    solaris)
        export CMAKE_GENERATOR=
        export MAKE=gmake
        export TAR=gtar
        ;;
    *)
        echo "Invalid target operating system (\$OS must be one of linux/osx/mingw/solaris)."
        exit 1
        ;;
esac

case "$ARCH" in
    aarch64) ;;
    arm) ;;
    x86) ;;
    x86_64) export MULTILIB=true ;;
    *)
        echo "Invalid target architecture (\$ARCH must be one of aarch64/arm/x86/x86_64)."
        exit 1
        ;;
esac

if [ -z "$LLVM_VERSION" ]; then
    export LLVM_VERSION=5.0.0-2
    export LLVM_USE_CMAKE=true
    echo "Defaulting to LLVM v${LLVM_VERSION}."
    echo "  Set LLVM_VERSION to the LLVM version to use, e.g. '${LLVM_VERSION}' (or 'release_38' or 'rev_123456' to fetch from SVN)."
    echo "  Export LLVM_USE_CMAKE=true if you want or need to use CMake to build LLVM (>= 3.9)."
    echo
fi

if [ -z "$BUILD_WITH_LTO" ]; then
    export BUILD_WITH_LTO=off
    if [ "$OS" == "osx" ]; then
        export BUILD_WITH_LTO=thin
    fi
    echo "Defaulting to BUILD_WITH_LTO=${BUILD_WITH_LTO}."
    echo "  Set BUILD_WITH_LTO to {off|full|thin} to override this default setting."
    echo "  BUILD_WITH_LTO is used when building both LLVM and LDC."
    echo
fi
