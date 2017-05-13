#!/bin/bash
# Builds an LDC release inside our build host Docker container.

set -eo pipefail

DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ $# -ne 1 ]; then
	echo "Usage: $0 PLATFORM"
	echo "    PLATFORM is one of $(ls -dm $DIR/ldc-builder-*/ | sed s:$DIR/ldc-builder-::g | sed s:/::g)."
	exit 1
fi
IMAGE=dlangldc/ldc-builder-$1

if [ -z "$LDC_VERSION" ]; then
    cat <<EOM
Set LDC_VERSION to the LDC version to build (e.g. '0.10.0').

This will be used for determining the branch name to fetch.

Use LDC_VERSION_SUFFIX to specify an additional suffix to append to the
version as it appears in file names (e.g. '-beta1').
EOM
    exit 1
fi

set -x

docker pull $IMAGE
docker run \
	--name ldcBuilder \
	-v $DIR/../ldc2-packaging:/ldc2-packaging \
	-e LDC_VERSION=$LDC_VERSION \
	-e LDC_VERSION_SUFFIX=$LDC_VERSION_SUFFIX \
	$IMAGE \
	sh -c "cd /ldc2-packaging && \
	./2-build-ldc.sh && \
	./2a-build-dub.sh && \
	./3-package-ldc.sh"
docker cp ldcBuilder:/build/ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$1.tar.xz .
docker cp ldcBuilder:/build/ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz .
docker rm ldcBuilder
