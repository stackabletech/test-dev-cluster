#!/bin/bash

set -e

source ${HOME}/.cargo/env

cd /agent-integration-tests

cargo clean

# --test-treads=1 is required to prevent the suite from failing on the first run.
# This is due to a bug in k3s.
RUST_BACKTRACE=1 cargo test -- --nocapture --test-threads=1

