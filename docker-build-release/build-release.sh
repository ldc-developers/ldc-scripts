#!/bin/bash
# Builds an LDC release inside our build host Docker container.

set -eou pipefail

DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ $# -ne 2 -a $# -ne 3 ]; then
	echo "Usage: $0 PLATFORM LDC_VERSION [LDC_VERSION_SUFFIX]"
	echo "    PLATFORM is one of $(ls -dm $DIR/ldc-builder-*/ | tr -d '\n' | sed s:$DIR/ldc-builder-::g | sed s:/::g)."
	exit 1
fi
IMAGE=dlangldc/ldc-builder-$1
LDC_VERSION=$2
LDC_VERSION_SUFFIX=
if [ $# -eq 3 ]; then
	LDC_VERSION_SUFFIX=$3
fi

function print_step {
	echo "$(tput setaf 6)$1$(tput sgr0)"
}
CONTAINER_NAME=ldc_builder_$$
print_step "$(tput bold)Building LDC $LDC_VERSION$LDC_VERSION_SUFFIX in container '$CONTAINER_NAME'..."

print_step "Fetching image $IMAGE"
docker pull $IMAGE

function cleanup {
	print_step "Removing container '$CONTAINER_NAME'"
	docker rm $CONTAINER_NAME
}
trap cleanup EXIT

print_step "Running release build scripts"
docker run \
	--name $CONTAINER_NAME \
	-v $DIR/../ldc2-packaging:/ldc2-packaging \
	-e LDC_VERSION=$LDC_VERSION \
	-e LDC_VERSION_SUFFIX=$LDC_VERSION_SUFFIX \
	$IMAGE \
	sh -c "cd /ldc2-packaging && \
	./2-build-ldc.sh && \
	./2a-build-dub.sh && \
	./2b-build-tools.sh && \
	./3-package-ldc.sh"

print_step "Copying over release archives"
docker cp $CONTAINER_NAME:/build/ldc2-$LDC_VERSION$LDC_VERSION_SUFFIX-$1.tar.xz .
docker cp $CONTAINER_NAME:/build/ldc-$LDC_VERSION$LDC_VERSION_SUFFIX-src.tar.gz .
