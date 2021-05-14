#!/usr/bin/env sh
#
# Run the spark operator.
#

set -e

CONTAINER_OS_NAME=${1:-debian}

PARENT_DIR=$(dirname $(pwd))

write_env_file() {
  tee .env > /dev/null <<EOF
STACKABLE_SCRIPTS_DIR=${PARENT_DIR}/test-dev-cluster/stackable-scripts
AGENT_SRC_DIR=${PARENT_DIR}/agent
AGENT_TESTS_SRC_DIR=${PARENT_DIR}/agent-integration-tests
SPARK_OPERATOR_SRC_DIR=${PARENT_DIR}/spark-operator
EOF
}

compose_up() {
  docker-compose -f ${CONTAINER_OS_NAME}/docker-compose.yml --env-file=.env up --detach --remove-orphans 
}

#--------------------
# main
#--------------------
{
  write_env_file
  compose_up
}
