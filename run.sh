#!/bin/bash

CONTAINER_OS_NAME=${1}

if [ "$CONTAINER_OS_NAME" == "" ]; then
    CONTAINER_OS_NAME=debian
else
    shift
fi

docker exec -it ${CONTAINER_OS_NAME}-agent $@