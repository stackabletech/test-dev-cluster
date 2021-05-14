#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

docker-compose -f ${CONTAINER_OS_NAME}/docker-compose.yml --env-file=.env down --volumes

rm .env

