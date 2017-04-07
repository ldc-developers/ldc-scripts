#!/bin/bash
# Builds an LDC release inside our build host Docker container.

set -euo pipefail

DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
if [ $# -ne 1 ]; then
	echo "Usage: $0 PLATFORM"
	echo "    PLATFORM is one of $(ls -dm ldc-builder-*/ | sed s:ldc-builder-::g | sed s:/::g)."
	exit 1
fi
IMAGE=dlangldc/ldc-builder-$1

set -x

docker pull $IMAGE

mkdir -p artifacts
docker run --rm \
	-v $DIR/../ldc2-packaging:/ldc2-packaging \
	-v artifacts:/artifacts \
	-e LDC_VERSION=1.2.0 \
	-e LDC_VERSION_SUFFIX=-beta2 \
	$IMAGE \
	sh -c "cd /ldc2-packaging && \
	./2-build-ldc.sh && \
	./2a-build-dub.sh && \
	./3-package-ldc.sh && \
	 cp /build/*z /artifacts"
