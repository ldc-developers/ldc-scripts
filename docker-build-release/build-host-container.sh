#!/bin/bash
# Builds a new host container version.

set -euo pipefail

# Need to use root directory as Docker context to be able to access
# ldc2-packaging scripts.
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
if [ $# -ne 1 ]; then
	echo "Usage: $0 PLATFORM"
	echo "    PLATFORM is one of $(ls -dm ldc-builder-*/ | sed s:ldc-builder-::g | sed s:/::g)."
	exit 1
fi
cd ..

set -x

# Explicitly pull down latest base image. Per Docker website recommendations,
# this is preferrable to doing apt-get upgrade in the container.
docker pull ubuntu:12.04

CONFIG=ldc-builder-$1
docker build -f $DIR/$CONFIG/Dockerfile -t dlangldc/$CONFIG .
docker push dlangldc/$CONFIG
