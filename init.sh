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
  local AGENT_SRC_DIR=dummy
  local AGENT_TESTS_SRC_DIR=dummy
  local OPERATOR_SRC_DIR=dummy

  case ${COMPONENT} in
  k3s)
    ;;
  agent)
    AGENT_SRC_DIR=${PARENT_DIR}/agent
    AGENT_TESTS_SRC_DIR=${PARENT_DIR}/agent-integration-tests
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

  docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env up --detach --remove-orphans 
}

maybe_install_agent() {
  if [ "$COMPONENT" != "agent" ]; then
    docker exec -t agent /stackable-scripts/install-agent.sh
  fi
}

#--------------------
# main
#--------------------
{
  write_env_file
  compose_up
  maybe_install_agent
}
