#!/bin/bash

set -x

# Assume the agent repo is in the same (base) folder as us
AGENT_SRC_DIR=$(dirname $(pwd))/agent

docker run --rm -v ${AGENT_SRC_DIR}:/agent stackabletech/debian-agent-base /agent-build-scripts/build.sh
