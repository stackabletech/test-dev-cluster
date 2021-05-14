#!/usr/bin/env sh

CONTAINER_OS_NAME=${1}
#COMPONENT_NAME=${2}

{
  shift;# shift;
  docker exec -it ${CONTAINER_OS_NAME}_agent_1 $@
}
