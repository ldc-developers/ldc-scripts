# Linux build environment for LDC binary release packages.
FROM ubuntu:12.04
LABEL maintainer "David Nadlinger <code@klickverbot.at>"

ARG DEBIAN_FRONTEND=noninteractive
# Build and test dependencies for LDC.
RUN apt-get -y update && apt-get -yq install \
	curl \
	gdb \
	git-core \
	libcurl4-openssl-dev \
	libcurl3:i386 \
	make \
	ninja-build \
	subversion \
	xz-utils \
	&& apt-get -y autoremove

# We work in /build as the path tends to leak into the binaries in the form of
# debug info, etc.
ENV BUILD_ROOT=/build
RUN mkdir ${BUILD_ROOT}
WORKDIR ${BUILD_ROOT}

# The 12.04 system GCC is too old for building recent LLVM versions, so grab a
# backport from the "unofficial-official" toolchain test PPA.
RUN apt-get -y update && apt-get -yq install python-software-properties && \
	add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get -y update && \
	apt-get -yq install g++-6-multilib
ENV CC=gcc-6 CXX=g++-6

# LLVM 4.0+ requires CMake >3.4 to build, so install it from the binaries.
# (We should set up a PPA for this, but getting the .deb to build without much
# Ubuntu packaging experience is a bit cumbersome. The binary installer just
# works.)
RUN mkdir -p tools/cmake
ENV CMAKE_INSTALLER=cmake-3.7.2-Linux-x86_64.sh
RUN curl -OL https://cmake.org/files/v3.7/${CMAKE_INSTALLER} && \
	sh ${CMAKE_INSTALLER} --prefix=${BUILD_ROOT}/tools/cmake --skip-license && \
	rm ${CMAKE_INSTALLER}
ENV PATH=${PATH}:${BUILD_ROOT}/tools/cmake/bin

# Build the LLVM libraries for LDC to use.
COPY ldc2-packaging/env.sh \
	ldc2-packaging/1-build-llvm.sh \
	${BUILD_ROOT}/
ENV LLVM_VERSION=4.0.0 LLVM_USE_CMAKE=1
RUN ./1-build-llvm.sh && rm -rf ${BUILD_ROOT}/src

# Install a host D compiler.
ENV HOST_LDC=ldc2-1.1.0-linux-x86_64
RUN curl -OL https://github.com/ldc-developers/ldc/releases/download/v1.1.0/${HOST_LDC}.tar.xz && \
	tar xf ${HOST_LDC}.tar.xz -C tools && \
	rm ${HOST_LDC}.tar.xz
ENV PATH=${PATH}:${BUILD_ROOT}/tools/${HOST_LDC}/bin
