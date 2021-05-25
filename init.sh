#!/usr/bin/env sh
#
# Initialize a testing environment with docker compose.
#
# Usage:
#
#   ./init.sh [debian|centos7|centos8] [agent|spark-operator|zookeeper-operator] [additional args for docker-compose]
#
# Examples:
#
# Initialize the cluster for testing the zookeeper-operator with 3 kubelets:
#
#   ./init.sh debian zookeeper-operator --scale agent=3
#

set -e

CONTAINER_OS_NAME=${1:-debian}
COMPONENT=${2:-agent}
shift
shift

. stackable-scripts/functions.sh

PARENT_DIR=$(dirname $(pwd))

write_env_file() {

  local ENV_FILE=.env

  local STACKABLE_SCRIPTS_DIR=${PARENT_DIR}/test-dev-cluster/stackable-scripts
  local AGENT_SRC_DIR=dummy
  local AGENT_TESTS_SRC_DIR=dummy
  local OPERATOR_SRC_DIR=dummy
  local OPERATOR_TESTS_SRC_DIR=dummy

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
    OPERATOR_TESTS_SRC_DIR=${PARENT_DIR}/zookeeper-operator-integration-tests
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
OPERATOR_TESTS_SRC_DIR=${OPERATOR_TESTS_SRC_DIR}
COMPONENT=${COMPONENT}
EOF

 }

compose_up() {

  local COMPOSE_DIR="debian"
  if [ "${CONTAINER_OS_NAME}" != "debian" ]; then
    COMPOSE_DIR=centos
  fi

  docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env up --detach --remove-orphans $@
}

maybe_install_agent() {

  if [ "$COMPONENT" = "agent" ]; then
    # No agent is installed here since it is mapped from the local folders.
    return
  fi

  #
  # Install the agent in all containers when testing an operator.
  #
  for AGENT_CONTAINER_NAME in $(docker ps | awk '/agent/ { print $NF }'); do
    info Install agent in container ${AGENT_CONTAINER_NAME}...
    docker exec -t ${AGENT_CONTAINER_NAME}  /stackable-scripts/install-agent.sh
    info "done."
  done

  info Install agent requirements...
  docker exec -t k3s /stackable-scripts/install-agent-reqs.sh
  info "done."

}

#--------------------
# main
#--------------------
{
  write_env_file
  compose_up $@
  maybe_install_agent
}

