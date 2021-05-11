#!/bin/bash

CONTAINER_OS_NAME=${1:-debian}

DOCKER_ARGS="--rm -t stackabletech/${CONTAINER_OS_NAME}-devel-base"

if [ "$CONTAINER_OS_NAME" == "centos7" ]; then
  DOCKER_ARGS="$DOCKER_ARGS --build-arg OS_VERSION=7 -f centos/Dockerfile"
elif [ "$CONTAINER_OS_NAME" == "centos8" ]; then
  DOCKER_ARGS="$DOCKER_ARGS --build-arg OS_VERSION=8 -f centos/Dockerfile"
elif [ "$CONTAINER_OS_NAME" == "debian" ]; then
  DOCKER_ARGS="$DOCKER_ARGS -f debian/Dockerfile"
fi

docker build ${DOCKER_ARGS} .

