#!/bin/bash

# Jenkins build steps
NODE_VERSIONS="0.8.28 0.9.12"

for v in $(seq 0 38); do
        NODE_VERSIONS="$NODE_VERSIONS 0.10.$v"
done

for v in $(seq 0 16); do
        NODE_VERSIONS="$NODE_VERSIONS 0.11.$v"
done

for v in $(seq 0 4); do
        NODE_VERSIONS="$NODE_VERSIONS 0.12.$v"
done

cd $DIR_NAME

docker build -t node-$DIR_NAME-builder .

for NODE_VERSION in $NODE_VERSIONS
do
	docker run --rm -e ACCESS_KEY=$ACCESS_KEY -e SECRET_KEY=$SECRET_KEY -e BUCKET_NAME=$BUCKET_NAME node-$DIR_NAME-builder bash build.sh $NODE_VERSION
    
done
