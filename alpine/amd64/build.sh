#!/bin/bash
set -ex
set -o pipefail

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }

# set env var
NODE_VERSION=$1
ARCH=alpine-amd64
BUCKET_NAME=$BUCKET_NAME
BINARYNAME=node-v$NODE_VERSION-linux-$ARCH-system-icu
TAR_FILE=$BINARYNAME.tar.gz

commit=($(echo "$(grep " v$NODE_VERSION" /commit-table)" | tr " " "\n"))
if [ -z $commit ]; then
	echo "commit for v$NODE_VERSION not found!"
	exit 1
fi

BUILD_FLAGS='--prefix=/ --shared-zlib --with-intl=system-icu'

# Enable lto from node v11 onwards
#if (version_ge $NODE_VERSION "11"); then
#	BUILD_FLAGS+=' --enable-lto'
#fi

# Add --with-intl=none flag and update binary name
if [ ! -z "$NONE_INTL" ]; then
	BUILD_FLAGS+=' --with-intl=none'
	BINARYNAME=node-no-intl-v$NODE_VERSION-linux-$ARCH
	TAR_FILE=$BINARYNAME.tar.gz
fi

# compile node
cd node \
	&& git checkout ${commit[0]} \
	&& ./configure $BUILD_FLAGS \
   	&& make -j$(nproc) \
   	&& make install DESTDIR=$BINARYNAME PORTABLE=1 \
   	&& tar -cf $BINARYNAME.tar $BINARYNAME \
	&& rm -rf $BINARYNAME \
	&& gzip -c -f -9 $BINARYNAME.tar > $BINARYNAME.tar.gz \
	&& curl -SLO "http://resin-packages.s3.amazonaws.com/SHASUMS256.txt" \
	&& sha256sum $TAR_FILE >> SHASUMS256.txt \
	&& cd /

# Upload to S3 (using AWS CLI)
printf "$ACCESS_KEY\n$SECRET_KEY\n$REGION_NAME\n\n" | aws configure
aws s3 cp node/$TAR_FILE s3://$BUCKET_NAME/node/v$NODE_VERSION/
aws s3 cp node/SHASUMS256.txt s3://$BUCKET_NAME/
