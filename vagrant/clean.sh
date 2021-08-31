#!/usr/bin/env sh

CONTAINER_OS_NAME=${1:-debian}

for VAR in $(cat .env); do
  export $VAR
done

vagrant halt
#vagrant destroy -f -g

rm .env

