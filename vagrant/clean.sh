#!/usr/bin/env sh

CONTAINER_OS_NAME=${1}
COMMAND=${2:-halt}
VM_NAME=${3}

help() {
  echo "Usage: clean.sh <debian10|debian11|centos7|ceontos8> [halt|destroy|suspend] [<vm-name>]"
}

if test -z "${CONTAINER_OS_NAME}"; then
  help
  exit 1
fi

case ${COMMAND} in
  halt)
    CONTAINER_OS_NAME=${CONTAINER_OS_NAME} vagrant halt ${VM_NAME}
  ;;
  destroy)
    CONTAINER_OS_NAME=${CONTAINER_OS_NAME} vagrant destroy -f -g ${VM_NAME}
  ;;
  suspend)
    CONTAINER_OS_NAME=${CONTAINER_OS_NAME} vagrant suspend ${VM_NAME}
  ;;
  *)
    help
  ;;
esac
