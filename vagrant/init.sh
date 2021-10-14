#!/usr/bin/env sh

set -e

CONTAINER_OS_NAME=${1}
COMPONENT=${2}
VM_NODE_COUNT=${3:-1}

PARENT_DIR=$(dirname $(dirname $(pwd)))

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

check_args() {

  case ${CONTAINER_OS_NAME} in
  debian10|debian11|centos7|centos8)
    ;;
   *)
    usage
    fatal "Unknown container OS: ${CONTAINER_OS_NAME}."
    ;;
  esac

  case ${COMPONENT} in
  agent|spark-operator|zookeeper-operator|kafka-operator|monitoring-operator|opa-operator|nifi-operator|hdfs-operator|hbase-operator|trino-operator|hdfs-operator|hive-operator|hbase-operator)
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

    $0 <container-os-name> <component> <nodes>

Arguments:

    container-os-name: debian10, debian11, centos7, centos8
    component:         agent, zookeeper-operator, spark-operator, kafka-operator, monitoring-operator, opa-operator, nifi-operator, hdfs-operator, hbase-operator, trino-operator, hive-operator, hdfs-operator, hbase-operator
    nodes:             Optional. Number of agent VMs to start. Default: 1
USAGE
}

write_conf_file() {

  local ENV_FILE="conf/${CONTAINER_OS_NAME}.rb"

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
  *-operator)
    OPERATOR_SRC_DIR=${PARENT_DIR}/${COMPONENT}
    OPERATOR_TESTS_SRC_DIR=${PARENT_DIR}/${COMPONENT}-integration-tests
    if test ! -d ${OPERATOR_SRC_DIR}; then
      >&2 echo "Folder not found: ${OPERATOR_SRC_DIR}"
      exit 1
    fi
    if test ! -d ${OPERATOR_TESTS_SRC_DIR}; then
      mkdir -p ${OPERATOR_TESTS_SRC_DIR}
      echo "Created by the test-dev-cluster init.sh at $(date)" > ${OPERATOR_TESTS_SRC_DIR}/dummy
    fi
    ;;
  esac

  [ -d $(dirname  ENV_FILE) ] || mkdir -p $(dirname  ENV_FILE)

  tee ${ENV_FILE}  > /dev/null <<EOF
CONTAINER_OS_NAME="${CONTAINER_OS_NAME}"
STACKABLE_SCRIPTS_DIR="${STACKABLE_SCRIPTS_DIR}"
AGENT_SRC_DIR="${AGENT_SRC_DIR}"
AGENT_TESTS_SRC_DIR="${AGENT_TESTS_SRC_DIR}"
OPERATOR_SRC_DIR="${OPERATOR_SRC_DIR}"
OPERATOR_TESTS_SRC_DIR="${OPERATOR_TESTS_SRC_DIR}"
COMPONENT="${COMPONENT}"
K3S_BASE_BOX="generic/debian10"
AGENT_BASE_BOX="generic/${CONTAINER_OS_NAME}"
OPERATOR_BASE_BOX="generic/${CONTAINER_OS_NAME}"
NODE_COUNT=${VM_NODE_COUNT}
SUPPORTED_OS=["debian10","debian11","centos7","centos8"]
EOF

 }

vagrant_up() {
  CONTAINER_OS_NAME=${CONTAINER_OS_NAME} vagrant up --provider=virtualbox
}

#--------------------
# main
#--------------------
{
  check_args
  write_conf_file
  vagrant_up
  export CONTAINER_OS_NAME=${CONTAINER_OS_NAME} 
}

