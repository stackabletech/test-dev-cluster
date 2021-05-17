#!/bin/bash

set -e

source ${HOME}/.cargo/env

nohup /stackable-scripts/apply-spec-repository.sh >> /var/log/stackable/servicelogs/testmessages 2>&1 &

nohup /stackable-scripts/approve-cert-request.sh >> /var/log/stackable/servicelogs/testmessages 2>&1 &

export RUST_LOG=info,stackable_agent=trace

cd /agent && cargo run --verbose --target-dir /build/agent --bin stackable-agent

