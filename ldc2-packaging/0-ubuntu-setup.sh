#!/bin/bash

export OS=linux
export BUILD_ROOT=/build
. env.sh

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install subversion git-core g++-multilib make cmake libconfig++8-dev xz-utils

sudo mkdir $BUILD_ROOT
sudo chown ubuntu:ubuntu $BUILD_ROOT
