#!/bin/bash

# Jenkins build steps
cd $DIR_NAME

docker build --no-cache=true -t node-$DIR_NAME-builder .

for NODE_VERSION in $NODE_VERSIONS
do
	docker run --rm -e ACCESS_KEY=$ACCESS_KEY -e SECRET_KEY=$SECRET_KEY -e BUCKET_NAME=$BUCKET_NAME node-$DIR_NAME-builder bash build.sh $NODE_VERSION
    
done
