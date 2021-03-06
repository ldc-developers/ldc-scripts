# Linux build environment for LDC binary release packages.
FROM ubuntu:14.04
LABEL maintainer "David Nadlinger <code@klickverbot.at>"

ARG DEBIAN_FRONTEND=noninteractive
# Build and test dependencies for LDC.
RUN dpkg --add-architecture i386 && \
	apt-get -y update && apt-get -yq install \
	curl \
	gdb \
	git-core \
	libcurl4-openssl-dev \
	libcurl3:i386 \
	make \
	ninja-build \
	software-properties-common \
	subversion \
	xz-utils \
	&& apt-get -y autoremove

# We work in /build as the path tends to leak into the binaries in the form of
# debug info, etc.
ENV BUILD_ROOT=/build
RUN mkdir ${BUILD_ROOT}
WORKDIR ${BUILD_ROOT}

# The 14.04 system GCC is too old for building recent LLVM versions, so grab a
# backport from the "unofficial-official" toolchain test PPA.
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get -y update && \
	apt-get -yq install g++-6-multilib binutils-dev
ENV CC=gcc-6 CXX=g++-6

# LLVM 4.0+ requires CMake >3.4 to build, so install it from the binaries.
# (We should set up a PPA for this, but getting the .deb to build without much
# Ubuntu packaging experience is a bit cumbersome. The binary installer just
# works.)
RUN mkdir -p tools/cmake
ENV CMAKE_INSTALLER=cmake-3.9.1-Linux-x86_64.sh
RUN curl -OL https://cmake.org/files/v3.9/${CMAKE_INSTALLER} && \
	sh ${CMAKE_INSTALLER} --prefix=${BUILD_ROOT}/tools/cmake --skip-license && \
	rm ${CMAKE_INSTALLER}
ENV PATH=${PATH}:${BUILD_ROOT}/tools/cmake/bin

# Build the LLVM libraries for LDC to use.
COPY ldc2-packaging/env.sh \
	ldc2-packaging/1-build-llvm.sh \
	ldc2-packaging/1b-build-llvm-runtime.sh \
	${BUILD_ROOT}/
ENV LLVM_VERSION=5.0.0-2 LLVM_USE_CMAKE=1
RUN ./1-build-llvm.sh && ./1b-build-llvm-runtime.sh && rm -rf ${BUILD_ROOT}/src

# Install a host D compiler.
ENV HOST_LDC=ldc2-1.4.0-linux-x86_64
RUN curl -OL https://github.com/ldc-developers/ldc/releases/download/v1.4.0/${HOST_LDC}.tar.xz && \
	tar xf ${HOST_LDC}.tar.xz -C tools && \
	rm ${HOST_LDC}.tar.xz
ENV PATH=${PATH}:${BUILD_ROOT}/tools/${HOST_LDC}/bin
