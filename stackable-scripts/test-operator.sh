#!/bin/bash

set -e

source ${HOME}/.cargo/env

COMPONENT=$(pwd | sed 's/^\///')

cd /${COMPONENT}-integration-tests

# --test-treads=1 is required to prevent the suite from failing on the first run.
cargo test --target-dir /build/${COMPONENT}-integration-tests -- --nocapture --test-threads=1 $@


# TODO: maybe this is not wanted. Leave it to the devloper to decide.
# kill the operator to prepare for possible code changes.
# OPERATOR_BIN_NAME=stackable-$COMPONENT-server
# OPERATOR_PID=$(ps -u | grep ${OPERATOR_BIN_NAME} | grep -v grep | awk '{print $2}')
# if [ "${OPERATOR_PID}" != "" ]; then
#   kill -term ${OPERATOR_PID}
# fi

