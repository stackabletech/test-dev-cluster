#!/bin/bash

set -e

#[ -d /var/log/stackable/servicelogs ] || mkdir -p /var/log/stackable/servicelogs
#exec >> /var/log/stackable/servicelogs/testmessages
#exec 2>&1

source ${HOME}/.cargo/env

nohup /stackable-scripts/apply-spec-repository.sh

nohup /stackable-scripts/approve-cert-request.sh

export RUST_LOG=info,stackable_agent=trace

#
# Create folders if not already there
#
[ -d /opt/stackable/packages ] || mkdir -p /opt/stackable/packages 
[ -d /var/lib/stackable/stackable-agent ] || mkdir -p /var/lib/stackable/stackable-agent
[ -d /var/log/stackable/servicelogs ] || mkdir -p /var/log/stackable/servicelogs 
[ -d /etc/stackable/stackable-agent ] || mkdir -p /etc/stackable/stackable-agent
[ -d /etc/stackable/stackable-agent/secret ] || mkdir -m 700 /etc/stackable/stackable-agent/secret

cd /agent && cargo run --verbose --target-dir /build/agent --bin stackable-agent

