#!/bin/bash
#
# Wait a given amount of time (default 10 seconds) to approve certificate signing requests
#
# Usage:
#
# approve-cert-request.sh [time-to-leave-in-seconds]
#
set -e

TTL_SECONDS=${1:-10}

SLEEP_SECONDS=2
LOOP_COUNT=$(($TTL_SECONDS / $SLEEP_SECONDS))

for i in $(seq 1 ${LOOP_COUNT}); do
  sleep ${SLEEP_SECONDS}
  for CERT_SIGN_REQUEST in $(kubectl get certificatesigningrequests | awk '/Pending/ {print $1}'); do
    kubectl certificate approve ${CERT_SIGN_REQUEST}
  done
done

