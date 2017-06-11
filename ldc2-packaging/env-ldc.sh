#!/usr/bin/env bash

. env.sh

if [ -z "$LDC_VERSION" ]; then
    cat <<EOM
Set LDC_VERSION to the LDC version to build (e.g. '0.10.0').

This will be used for determining the branch name to fetch.

Use LDC_VERSION_SUFFIX to specify an additional suffix to append to the
version as it appears in file names (e.g. '-beta1').
EOM
    exit 1
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

if [ -z "$DUB_VERSION" ]; then
    # Will be used in the git checkout command.
    export DUB_VERSION=v1.3.0
    echo "Defaulting to DUB ${DUB_VERSION}."
    echo "  Set DUB_VERSION to the DUB version to use, e.g. '${DUB_VERSION}'."
    echo
fi

set -x

export PKG_BASE=ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$OS-$ARCH
