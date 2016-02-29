#!/bin/bash

cd $DISTRO
cd $ARCH

docker build --no-cache=true -t node-$DISTRO-$ARCH-builder .

for NODE_VERSION in $NODE_VERSIONS
do
	docker run --rm -e ACCESS_KEY=$ACCESS_KEY \
					-e SECRET_KEY=$SECRET_KEY \
					-e BUCKET_NAME=$BUCKET_NAME node-$DISTRO-$ARCH-builder bash build.sh $NODE_VERSION
done
