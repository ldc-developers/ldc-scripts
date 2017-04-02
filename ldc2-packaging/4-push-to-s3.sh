#!/usr/bin/env bash

. env-ldc.sh

s3cmd --configure
s3cmd put --acl-public --guess-mime-type $BUILD_ROOT/$PKG_BASE.tar.gz $BUILD_ROOT/$PKG_BASE.tar.xz s3://release.ldc
