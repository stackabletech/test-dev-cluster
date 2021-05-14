#!/bin/bash

set -e

source ${HOME}/.cargo/env

#export RUST_LOG=info,stackable_agent=trace

cargo run --verbose --target-dir /build/spark-operator

