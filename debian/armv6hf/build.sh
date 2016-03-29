#!/bin/bash
set -e
set -o pipefail

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=armv6hf
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=$BUCKET_NAME

BUILD_FLAGs='--without-snapshot'

# compile node
cd node \
	&& commit=($(echo "$(grep " v$NODE_VERSION" /commit-table)" | tr " " "\n")) \
	&& git checkout ${commit[0]} \
	&& make -j$(nproc) binary DESTCPU=$ARCH CONFIG_FLAGS=$BUILD_FLAGs \
	&& mv node-v$NODE_VERSION-linux-$ARCH.tar.gz $TAR_FILE \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt" \
	&& sha256sum $TAR_FILE >> SHASUMS256.txt \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
aws s3 cp node/SHASUMS256.txt s3://$BUCKET_NAME/
