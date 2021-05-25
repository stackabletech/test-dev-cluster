#!/bin/bash

set -e

source ${HOME}/.cargo/env

cd /agent-integration-tests

# --test-treads=1 is required to prevent the suite from failing on the first run.
# This is due to a bug in k3s.
cargo test --target-dir /build/agent-integration-tests -- --nocapture --test-threads=1 $@


# TODO: maybe this is not wanted. Leave it to the devloper to decide.
# kill the agent to prepare for possible code changes
# AGENT_BIN_NAME=stackable-agent
# AGENT_PID=$(ps -u | grep ${AGENT_BIN_NAME} | grep -v grep | awk '{print $2}')
# if [ "${AGENT_PID}" != "" ]; then
#   kill -term ${AGENT_PID}
# fi

