#!/bin/bash
set -e

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=armv7hf
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=$BUCKET_NAME

# compile node
cd node \
	&& git checkout v$NODE_VERSION \
	&& make -j$(nproc) binary DESTCPU=$ARCH \
	&& mv node-v$NODE_VERSION-linux-x86.tar.gz $TAR_FILE \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
