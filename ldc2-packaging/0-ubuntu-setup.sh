#!/usr/bin/env bash

set -e

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install subversion git-core g++-multilib make cmake xz-utils s3cmd

BUILD_ROOT=/build
echo "Preparing ${BUILD_ROOT} as build root directory."
sudo mkdir $BUILD_ROOT
sudo chown ubuntu:ubuntu $BUILD_ROOT
