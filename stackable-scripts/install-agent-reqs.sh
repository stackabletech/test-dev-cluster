#!/bin/bash
#
# Set up agent requirements:
# * approve certificate signing request (runs in the background)
# * install stackable repository CRD and CR.
#
wait_for_k3s() {
  until kubectl get crds; do
    >&2 echo "k3s is not running yet."
    sleep 1
  done
}

{
  wait_for_k3s
  /stackable-scripts/apply-spec-repository.sh
  /stackable-scripts/apply-cr-repository.sh
  /stackable-scripts/approve-cert-request.sh
}
