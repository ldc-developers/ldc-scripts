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

if [ -z "$DUB_VERSION" ]; then
    # Will be used in the git checkout command.
    export DUB_VERSION=v1.5.0
    echo "Defaulting to DUB ${DUB_VERSION}."
    echo "  Set DUB_VERSION to the DUB version to use, e.g. '${DUB_VERSION}'."
    echo
fi

set -x

export PKG_BASE=ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$OS-$ARCH
