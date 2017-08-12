# Linux build environment for LDC binary release packages.
FROM arm64v8/ubuntu:16.04
LABEL maintainer "David Nadlinger <code@klickverbot.at>"

ARG DEBIAN_FRONTEND=noninteractive
# Build and test dependencies for LDC.
# devel: valgrind
RUN apt-get -y update && apt-get -yq install \
	cmake \
	curl \
	gdb \
	git-core \
	g++ \
	g++-multilib-arm-linux-gnueabihf \
	libcurl4-openssl-dev \
	make \
	ninja-build \
	python \
	python-pip \
	subversion \
	xz-utils \
	unzip \
	vim \
	zip \
	&& apt-get -y autoremove

RUN pip install lit

# We work in /build as the path tends to leak into the binaries in the form of
# debug info, etc.
ENV BUILD_ROOT=/build
RUN mkdir ${BUILD_ROOT}
WORKDIR ${BUILD_ROOT}

# Build the LLVM libraries for LDC to use.
COPY ldc2-packaging/env.sh \
	ldc2-packaging/1-build-llvm.sh \
	${BUILD_ROOT}/
ENV LLVM_VERSION=4.0.1 LLVM_USE_CMAKE=1
RUN ./1-build-llvm.sh && rm -rf ${BUILD_ROOT}/src
