#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

COMPOSE_DIR="debian"
if [ "${CONTAINER_OS_NAME}" != "debian" ]; then
  COMPOSE_DIR=centos
fi

docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env down --volumes

rm .env

