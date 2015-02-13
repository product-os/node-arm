#!/bin/bash
set -e

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=armv6hf
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=resin-packages

# compile node
cd node \
	&& git checkout v$NODE_VERSION \
	&& make binary DESTCPU=$ARCH \
	&& cd /

# Upload to S3

sed -i -e "s/ACCESS/$ACCESS_KEY/" -e "s/SECRET/$SECRET_KEY/" /.s3cfg
s3cmd -P put -c /.s3cfg node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
