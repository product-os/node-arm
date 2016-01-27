#!/bin/bash
set -e

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=armv6hf
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION
BUCKET_NAME=$BUCKET_NAME

# compile node
cd node \
	&& git checkout v$NODE_VERSION \
	&& ./configure --without-snapshot --dest-cpu=$ARCH --prefix / \
	&& make install -j$(nproc) DESTDIR=$TAR_FILE V=1 PORTABLE=1 \
	&& cp LICENSE $TAR_FILE \
	&& tar -cvzf $TAR_FILE.tar.gz $TAR_FILE \
	&& rm -rf $TAR_FILE \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE.tar.gz s3://$BUCKET_NAME/node/v$NODE_VERSION/
