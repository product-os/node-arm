#!/bin/bash
set -e
set -o pipefail

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

commit=($(echo "$(grep " v$NODE_VERSION" /commit-table)" | tr " " "\n"))
if [ -z $commit ]; then
	echo "commit for v$NODE_VERSION not found!"
	exit 1
fi

# compile node
cd node \
	&& git checkout ${commit[0]} \
	&& make -j$(nproc) binary DESTCPU="$ARCH" CONFIG_FLAGS="$BUILD_FLAGs" \
	&& mv node-v$NODE_VERSION-linux-$ARCH.tar.gz $TAR_FILE \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt" \
	&& sha256sum $TAR_FILE >> SHASUMS256.txt \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
aws s3 cp node/SHASUMS256.txt s3://$BUCKET_NAME/
