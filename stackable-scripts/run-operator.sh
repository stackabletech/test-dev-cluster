#!/bin/bash

set -e

#[ -d /var/log/stackable/servicelogs ] || mkdir -p /var/log/stackable/servicelogs
#exec >> /var/log/stackable/servicelogs/testmessages
#exec 2>&1

source ${HOME}/.cargo/env

RUST_LOG=info
COMPONENT=$(pwd | sed 's/^\///')

OPERATOR_BIN_NAME=stackable-$COMPONENT

cargo run --verbose --target-dir /build/operator --bin ${OPERATOR_BIN_NAME} -- $@

