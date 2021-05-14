#!/usr/bin/env sh
#
# Initialize a testing environment with docker compose.
#
# Usage:
#
#   ./init.sh [debian|centos7|centos8] [agent|spark-operator|zookeeper-operator]
#


set -e

CONTAINER_OS_NAME=${1:-debian}
COMPONENT=${2:-agent}

PARENT_DIR=$(dirname $(pwd))

# --- helper functions for logs ---
info()
{
    echo '[INFO] ' "$@"
}
warn()
{
    echo '[WARN] ' "$@" >&2
}
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}

write_env_file() {

  local ENV_FILE=.env

  local STACKABLE_SCRIPTS_DIR=${PARENT_DIR}/test-dev-cluster/stackable-scripts
  local AGENT_SRC_DIR=${PARENT_DIR}/agent
  local AGENT_TESTS_SRC_DIR=${PARENT_DIR}/agent-integration-tests
  local OPERATOR_SRC_DIR=dummy

  case ${COMPONENT} in
  agent)

    ;;
  spark-operator)
    OPERATOR_SRC_DIR=${PARENT_DIR}/spark-operator
    ;;
  zookeeper-operator)
    OPERATOR_SRC_DIR=${PARENT_DIR}/zookeeper-operator
    ;;
   *)
    fatal "Unknown component: ${COMPONENT}. Valid values are: agent, spark-operator, zookeeper-operator"
  esac

    tee ${ENV_FILE}  > /dev/null <<EOF
CONTAINER_OS_NAME=${CONTAINER_OS_NAME}
STACKABLE_SCRIPTS_DIR=${STACKABLE_SCRIPTS_DIR}
AGENT_SRC_DIR=${AGENT_SRC_DIR}
AGENT_TESTS_SRC_DIR=${AGENT_TESTS_SRC_DIR}
OPERATOR_SRC_DIR=${OPERATOR_SRC_DIR}
EOF

 }

compose_up() {

  local COMPOSE_DIR="debian"
  if [ "${CONTAINER_OS_NAME}" != "debian" ]; then
    COMPOSE_DIR=centos
  fi

  local COMPOSE_SERVICES="k3s"

  case ${COMPONENT} in
  agent)
    COMPOSE_SERVICES="${COMPOSE_SERVICES} agent"
    ;;
  spark-operator)
    COMPOSE_SERVICES="${COMPOSE_SERVICES} agent operator"
    ;;
  *)
    fatal "Unknown component: ${COMPONENT}. Valid values are: agent, spark-operator, zookeeper-operator"
  esac

  docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env up --detach --remove-orphans ${COMPOSE_SERVICES}
}

#--------------------
# main
#--------------------
{
  write_env_file
  compose_up
}
