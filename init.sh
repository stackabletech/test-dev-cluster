#!/usr/bin/env sh
#
# Initialize a testing environment with docker compose.
#
# Usage:
#
#   ./init.sh <container-os-name> <component> [compose-arguments]
#
# Examples:
#
# Initialize the cluster for testing the zookeeper-operator with 3 kubelets:
#
#   ./init.sh debian zookeeper-operator --scale agent=3
#

set -e

CONTAINER_OS_NAME=${1}
COMPONENT=${2}
shift; shift;
COMPOSE_ARGS=$@

. stackable-scripts/functions.sh

PARENT_DIR=$(dirname $(pwd))

check_args() {

  case ${CONTAINER_OS_NAME} in
  debian|centos7|centos8)
    ;;
   *)
    usage
    fatal "Unknown container OS: ${CONTAINER_OS_NAME}."
    ;;
  esac

  case ${COMPONENT} in
  agent|spark-operator|zookeeper-operator|kafka-operator)
    ;;
   *)
    usage
    fatal "Unknown component: ${COMPONENT}."
    ;;
  esac
}

usage() {
  cat <<USAGE
Usage:

    $0 <container-os-name> <component> [compose-arguments]

Arguments:

    container-os-name: debian, centos7, centos8
    component:         agent, zookeeper-operator, spark-operator, kafka-operator
    compose-arguments: Optional. Example: --scale agent=3
USAGE
}

write_env_file() {

  local ENV_FILE=.env

  local STACKABLE_SCRIPTS_DIR=${PARENT_DIR}/test-dev-cluster/stackable-scripts
  local AGENT_SRC_DIR=dummy
  local AGENT_TESTS_SRC_DIR=dummy
  local OPERATOR_SRC_DIR=dummy
  local OPERATOR_TESTS_SRC_DIR=dummy

  case ${COMPONENT} in
  agent)
    AGENT_SRC_DIR=${PARENT_DIR}/${COMPONENT}
    AGENT_TESTS_SRC_DIR=${PARENT_DIR}/${COMPONENT}-integration-tests
    ;;
  spark-operator|zookeeper-operator|kafka-operator)
    OPERATOR_SRC_DIR=${PARENT_DIR}/${COMPONENT}
    OPERATOR_TESTS_SRC_DIR=${PARENT_DIR}/${COMPONENT}-integration-tests
    ;;
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

  local SERVICES=k3s
  case ${COMPONENT} in
    agent)
      SERVICES="${SERVICES} agent"
    ;;
    zookeeper-operator|spark-operator)
      SERVICES="${SERVICES} agent operator"
    ;;
    kafka-operator)
      SERVICES="${SERVICES} agent operator sidecar"
    ;;
  esac
  docker-compose -f ${COMPOSE_DIR}/docker-compose.yml --env-file=.env up --detach --remove-orphans ${COMPOSE_ARGS} ${SERVICES}
}

maybe_install_agent() {

  if [ "$COMPONENT" = "agent" ]; then
    # No agent is installed here since it is mapped from the local folders.
    return
  fi

  #
  # Install the agent in all containers when testing an operator.
  #
  for AGENT_CONTAINER_NAME in $(docker ps --filter name=agent --format '{{.Names}}' | sort); do
    info Start agent install in container ${AGENT_CONTAINER_NAME}...
    docker exec -t ${AGENT_CONTAINER_NAME}  /stackable-scripts/install-agent.sh
    info Finish agent install.
  done

  info Start agent requirements install...
  docker exec -t k3s /stackable-scripts/install-reqs.sh agent
  info Finish agent requirements install.
}

maybe_label_agent_nodes() {
    local NODE_ID=""
    local NODE_NUM=""

  if [ "$COMPONENT" = "agent" ]; then
    # No agent is installed here since it is mapped from the local folders.
    return
  fi

  #
  # Give k3s time to register nodes properly. Sometimes "kubectl get nodes" lists several nodes
  # but "kubectl label node" fails because the node is not available.
  #
  sleep 5

  #
  # Label each node with node=<num> where num corresponds to the container name.
  #
  # For example if container name is "debian_agent_3", then label this agent with "node=3"
  #
  for PAIR_ID_NAME in $(docker ps --filter name=agent --format '{{.ID}}-{{.Names}}' | sort -t'-' -k2); do
    NODE_ID=$(echo $PAIR_ID_NAME | awk '{split($0, a, "-"); print a[1]}')
    NODE_NUM=$(echo $PAIR_ID_NAME | awk '{split($0, a, "_"); print a[3]}')
    info Start node labeling for node ${NODE_ID} with node=${NODE_NUM}
    docker exec -t k3s kubectl label node ${NODE_ID} node=${NODE_NUM}
    info Finish node labeling.
  done
}

maybe_install_sidecar() {

  if [ "$COMPONENT" = "kafka-operator" ]; then
    # Here we install the CRD and CR first to avoid a bug in the operator
    info Start zookeeper operator requirements install ...
    docker exec -t k3s /stackable-scripts/install-reqs.sh zookeeper-operator
    info Finish zookeeper operator requirements install.

    info Start zookeeper operator install...
    local SIDECAR_CONTAINER_NAME=$(docker ps -q --filter name=sidecar --format '{{.Names}}')
    docker exec -t ${SIDECAR_CONTAINER_NAME}  /stackable-scripts/install-zookeeper-operator.sh
    info Finish zookeeper operator install.
  fi
}

#--------------------
# main
#--------------------
{
  check_args
  write_env_file
  compose_up
  maybe_install_agent
  maybe_label_agent_nodes
  maybe_install_sidecar
}

