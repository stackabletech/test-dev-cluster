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
STACKABLE_SCRIPTS_DIR=${STACKABLE_SCRIPTS_DIR}
AGENT_SRC_DIR=${AGENT_SRC_DIR}
AGENT_TESTS_SRC_DIR=${AGENT_TESTS_SRC_DIR}
OPERATOR_SRC_DIR=${OPERATOR_SRC_DIR}
EOF

 }

compose_up() {

  case ${COMPONENT} in
  agent)
    docker-compose -f ${CONTAINER_OS_NAME}/docker-compose.yml --env-file=.env up --detach --remove-orphans k3s agent
    ;;
  spark-operator)
    docker-compose -f ${CONTAINER_OS_NAME}/docker-compose.yml --env-file=.env up --detach --remove-orphans k3s agent operator
    ;;
  *)
    fatal "Unknown component: ${COMPONENT}. Valid values are: agent, spark-operator, zookeeper-operator"
  esac
}

#--------------------
# main
#--------------------
{
  write_env_file
  compose_up
}
