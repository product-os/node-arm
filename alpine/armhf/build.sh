#!/bin/bash
set -e
set -o pipefail

# set env var
NODE_VERSION=$1
ARCH=alpine-armhf
TAR_FILE=node-v$NODE_VERSION-linux-$ARCH.tar.gz
BUCKET_NAME=$BUCKET_NAME
BINARYNAME=node-v$NODE_VERSION-linux-$ARCH

# compile node
cd node \
	&& git checkout v$NODE_VERSION \
	&& ./configure --prefix=/ --shared-zlib --shared-openssl \
   	&& make -j$(nproc) -C out mksnapshot \
   	&& paxctl -c -m out/Release/mksnapshot \
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
