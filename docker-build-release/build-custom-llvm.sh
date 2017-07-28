#!/bin/bash
# Builds a custom LLVM (with enabled assertions) inside a container and
# copies the resulting archive to the host's working directory.

set -exo pipefail

if [ -z "$LLVM_VERSION" ]; then
	echo "Please set the LLVM_VERSION environment variable to something like '4.0.1'."
	exit 1
fi

if [ -z "$IMAGE" ]; then
	IMAGE=ubuntu:14.04
	echo "Environment variable IMAGE not set, defaulting to '$IMAGE'."
fi

docker pull $IMAGE

CONTAINER_NAME=llvm_builder_$$
function cleanup {
	echo "Removing container '$CONTAINER_NAME'"
	docker rm $CONTAINER_NAME
}
trap cleanup EXIT

docker run \
	--name $CONTAINER_NAME \
	$IMAGE \
	sh -c "set -x && \
	apt-get update && \
	apt-get -yq install software-properties-common && \
	add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
	apt-get update && \
	apt-get -yq install curl ninja-build g++-4.9 gcc-4.9-plugin-dev && \
	curl -OL https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.sh && \
	sh cmake-3.7.2-Linux-x86_64.sh --prefix=/usr --skip-license && \
	mkdir /build && \
	cd /build && \
	curl -OL http://releases.llvm.org/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz && \
	tar xJf llvm-$LLVM_VERSION.src.tar.xz && \
	mv llvm-$LLVM_VERSION.src llvm && \
	cd llvm/tools && \
	curl -OL http://releases.llvm.org/$LLVM_VERSION/lld-$LLVM_VERSION.src.tar.xz && \
	tar xJf lld-$LLVM_VERSION.src.tar.xz && \
	mv lld-$LLVM_VERSION.src lld && \
	cd ../.. && \
	mkdir $LLVM_VERSION && \
	cd $LLVM_VERSION && \
	CC=gcc-4.9 CXX=g++-4.9 cmake -G Ninja -DCMAKE_BUILD_TYPE=Release \
		-DLLVM_ENABLE_ASSERTIONS=ON \
		-DLLVM_BINUTILS_INCDIR=/usr/lib/gcc/x86_64-linux-gnu/4.9/plugin/include \
		-DCMAKE_INSTALL_PREFIX=/build/llvm-$LLVM_VERSION ../llvm && \
	ninja install && \
	cd .. && \
	tar -cJf llvm-$LLVM_VERSION.tar.xz llvm-$LLVM_VERSION"

docker cp $CONTAINER_NAME:/build/llvm-$LLVM_VERSION.tar.xz .
