#!/bin/bash -ex

list=$(docker ps -aq)

if [ -n "$list" ]; then
    docker rm -f $list
fi
