#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

DOCKER_ARGS="--force-rm -t docker.stackable.tech/${CONTAINER_OS_NAME}-devel-base"

if [ "$CONTAINER_OS_NAME" = "centos7" ]; then
  DOCKER_ARGS="$DOCKER_ARGS --build-arg OS_VERSION=7 -f centos/Dockerfile"
elif [ "$CONTAINER_OS_NAME" = "centos8" ]; then
  DOCKER_ARGS="$DOCKER_ARGS --build-arg OS_VERSION=8 -f centos/Dockerfile"
elif [ "$CONTAINER_OS_NAME" = "debian" ]; then
  DOCKER_ARGS="$DOCKER_ARGS -f debian/Dockerfile"
elif [ "$CONTAINER_OS_NAME" = "k3s" ]; then
  DOCKER_ARGS="--force-rm -t docker.stackable.tech/${CONTAINER_OS_NAME} -f k3s/Dockerfile"
fi

docker build ${DOCKER_ARGS} .

