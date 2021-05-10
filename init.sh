#!/bin/bash

set -x

CONTAINER_OS_NAME=${1:-debian}

# Assume the agent repo is in the same (base) folder as us
AGENT_SRC_DIR=$(dirname $(pwd))/agent

# Assume the agent repo is in the same (base) folder as us
AGENT_TEST_SRC_DIR=$(dirname $(pwd))/agent-integration-tests

#
# The --priviledged flag is required for systemd to be able to start some services (like networkd)
# in the container.
#
docker run --privileged --rm -d --memory-swappiness 0 --name ${CONTAINER_OS_NAME}-agent \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v ${AGENT_SRC_DIR}:/agent \
  -v ${AGENT_TEST_SRC_DIR}:/agent-integration-tests \
  stackabletech/${CONTAINER_OS_NAME}-devel-base

docker exec ${CONTAINER_OS_NAME}-agent /root/run-k3s.sh

