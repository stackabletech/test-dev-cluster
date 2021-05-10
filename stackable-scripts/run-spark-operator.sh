#!/bin/bash

set -e

source ${HOME}/.cargo/env

#export RUST_LOG=info,stackable_agent=trace

cd /spark-operator && cargo clean && cargo run --verbose

