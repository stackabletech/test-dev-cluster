#!/usr/bin/env sh

COMMAND=${1:-halt}
VM_NAME=${2}

case ${COMMAND} in
  halt)
    vagrant halt ${VM_NAME}
  ;;
  destroy)
    vagrant destroy -f -g ${VM_NAME}
  ;;
  suspend)
    vagrant suspend ${VM_NAME}
  ;;
esac
