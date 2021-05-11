#!/usr/bin/env sh
#
# Run the spark operator.
#

set -e

PARENT_DIR=$(dirname $(pwd))

write_env_file() {
  tee .env > /dev/null <<EOF
STACKABLE_SCRIPTS_DIR=${PARENT_DIR}/test-dev-cluster/stackable-scripts
AGENT_SRC_DIR=${PARENT_DIR}/agent
SPARK_OPERATOR_SRC_DIR=${PARENT_DIR}/spark-operator
EOF
}

run_spark_operator() {
  docker-compose -f debian/docker-compose.yml --env-file=.env run spark_operator
}

#--------------------
# main
#--------------------
{
  write_env_file
  run_spark_operator
}
