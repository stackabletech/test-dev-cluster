#!/bin/bash

set -e

source ${HOME}/.cargo/env

nohup $HOME/approve-cert-request.sh > /dev/null 2>&1 &

export RUST_LOG=info,stackable_agent=trace

cd /agent && cargo run --verbose --target-dir /build/agent --bin stackable-agent

