#!/bin/bash

set -e

source ${HOME}/.cargo/env

COMPONENT=$(pwd | sed 's/^\///')

cd /${COMPONENT}-integration-tests

# --test-treads=1 is required to prevent the suite from failing on the first run.
cargo test --target-dir /build/${COMPONENT}-integration-tests -- --nocapture --test-threads=1 $@

