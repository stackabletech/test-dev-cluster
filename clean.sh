#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

case "${CONTAINER_OS_NAME}" in
  debian)
    COMPOSE_DIR="debian"
  ;;
  centos*)
    COMPOSE_DIR="centos"
  ;;
  *)
    >&2 echo Invalid container os name: ${CONTAINER_OS_NAME}
    exit 1
  ;;
esac

docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env down --volumes

rm .env

