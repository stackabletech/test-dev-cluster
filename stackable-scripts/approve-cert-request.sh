#!/bin/bash
#
# Wait a finite amount of time to approve certificate signing requests
#

for i in $(seq 1 5); do
  sleep 2
  for CERT_SIGN_REQUEST in $(kubectl get certificatesigningrequests | awk '/Pending/ {print $1}'); do
    kubectl certificate approve ${CERT_SIGN_REQUEST}
  done
done

