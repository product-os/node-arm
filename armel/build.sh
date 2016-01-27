#!/bin/bash
set -e

# comparing version: http://stackoverflow.com/questions/16989598/bash-comparing-version-numbers
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=armel
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=$BUCKET_NAME

BUILD_FLAGs='--without-snapshot --with-arm-float-abi=softfp'
# --with-arm-fpu flag is not available for node versions 0.12.x and 0.10.x
if version_le "$NODE_VERSION" "4"; then
	BUILD_FLAGs+=' --with-arm-fpu=vfp'
fi

# compile node
cd node \
	&& git checkout v$NODE_VERSION \
	&& make -j$(nproc) binary DESTCPU=$ARCH CONFIG_FLAGS=$BUILD_FLAGs \
	&& mv node-v$NODE_VERSION-linux-$ARCH.tar.gz $TAR_FILE \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
