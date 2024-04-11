#!/bin/bash
set -ex
set -o pipefail

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }

# set env var
NODE_VERSION=$1
ARCH_VERSION=amd64
DEST_DIR=node-v$NODE_VERSION-linux-$ARCH_VERSION
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
BUCKET_NAME=$BUCKET_NAME

commit=($(echo "$(grep " v$NODE_VERSION" /commit-table)" | tr " " "\n"))
if [ -z $commit ]; then
	echo "commit for v$NODE_VERSION not found!"
	exit 1
fi

BUILD_FLAGS="--prefix=/"

# Enable lto from node v11 onwards
#if (version_ge $NODE_VERSION "11"); then
#	BUILD_FLAGS+=' --enable-lto'
#fi

# Add --with-intl=none flag and update binary name
if [ ! -z "$NONE_INTL" ]; then
	BUILD_FLAGS+=' --with-intl=none'
	TAR_FILE=node-no-intl-v$NODE_VERSION-linux-$ARCH_VERSION.tar.gz
fi

# compile node
cd node \
	&& git checkout ${commit[0]} \
	&& ./configure $BUILD_FLAGS \
	&& cat config.gypi \
	&& make install -j$(nproc) DESTDIR=$DEST_DIR V=1 PORTABLE=1 \
	&& cp LICENSE $DEST_DIR \
	&& tar -cvzf $TAR_FILE $DEST_DIR \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt" \
	&& sha256sum $TAR_FILE >> SHASUMS256.txt \
	&& cd /

# Upload to S3 (using AWS CLI)
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
aws s3 cp node/SHASUMS256.txt s3://$BUCKET_NAME/
