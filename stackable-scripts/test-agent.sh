#!/bin/bash

set -e

source ${HOME}/.cargo/env

cd /agent-integration-tests

# --test-treads=1 is required to prevent the suite from failing on the first run.
# This is due to a bug in k3s.
cargo test --target-dir /build/agent-integration-tests -- --nocapture --test-threads=1

