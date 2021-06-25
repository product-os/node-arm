#!/bin/bash

function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" != "$1"; }

cp -f commit-table $DISTRO/$ARCH
cd $DISTRO
cd $ARCH

docker build --no-cache=true -t node-$DISTRO-$ARCH-builder .

for NODE_VERSION in $NODE_VERSIONS
do
	if [ $DISTRO == 'debian' ]; then
		if version_le $NODE_VERSION 10; then
			sed -e s~#{SUITE}~jessie~g Dockerfile.tpl > Dockerfile
		else
			sed -e s~#{SUITE}~buster~g Dockerfile.tpl > Dockerfile
		fi
		docker build --no-cache=true -t node-$DISTRO-$ARCH-builder .		
	fi
	docker run --rm -e NONE_INTL=$NONE_INTL \
					-e ACCESS_KEY=$ACCESS_KEY \
					-e SECRET_KEY=$SECRET_KEY \
					-e BUCKET_NAME=$BUCKET_NAME node-$DISTRO-$ARCH-builder bash build.sh $NODE_VERSION
done
rm -f $DISTRO/$ARCH/commit-table
