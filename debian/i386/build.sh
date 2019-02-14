#!/bin/bash
set -e
set -o pipefail

# set env var
NODE_VERSION=$1
ARCH=arm
ARCH_VERSION=i386
DEST_DIR=node-v$NODE_VERSION-linux-$ARCH_VERSION
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=$BUCKET_NAME

commit=($(echo "$(grep " v$NODE_VERSION" /commit-table)" | tr " " "\n"))
if [ -z $commit ]; then
	echo "commit for v$NODE_VERSION not found!"
	exit 1
fi

BUILD_FLAGs="--prefix / --dest-cpu=ia32"

# compile node
cd node \
	&& git checkout ${commit[0]} \
	&& ./configure $BUILD_FLAGs \
	&& sed -i "s/'want_separate_host_toolset':/'v8_target_arch':'x87','want_separate_host_toolset':/" config.gypi \
	&& cat config.gypi \
	&& make install -j$(nproc) DESTDIR=$DEST_DIR V=1 PORTABLE=1 \
	&& cp LICENSE $DEST_DIR \
	&& tar -cvzf $TAR_FILE $DEST_DIR \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt" \
	&& sha256sum $TAR_FILE >> SHASUMS256.txt \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
aws s3 cp node/SHASUMS256.txt s3://$BUCKET_NAME/
