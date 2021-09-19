#!/bin/bash
#Update version with each release.
source $PWD/vars.env
docker build --build-arg MONERO_VERSION=$MONERO_VERSION \
             --build-arg MONERO_SHA256=$MONERO_SHA256 \
             --build-arg SERVER=$SERVER \
             --tag kannix-monero-full-node:local-$MONERO_VERSION . \
             --network host
