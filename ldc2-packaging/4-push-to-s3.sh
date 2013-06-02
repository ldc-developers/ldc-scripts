#!/bin/bash

. env.sh

s3cmd --configure
s3cmd put $BUILD_ROOT/$PKG_BASE.tar.gz $BUILD_ROOT/$PKG_BASE.tar.xz s3://release.ldc
