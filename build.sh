#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

docker build --rm -t stackabletech/${CONTAINER_OS_NAME}-devel-base -f ${CONTAINER_OS_NAME}/Dockerfile .

