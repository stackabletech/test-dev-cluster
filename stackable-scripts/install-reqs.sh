#!/bin/bash

COMPONENT=$1

#
# Set up agent requirements:
# * approve certificate signing request (runs in the background)
# * install stackable repository CRD and CR.
#
wait_for_k3s() {
  until kubectl get crds >/dev/null 2>&1; do
    >&2 echo "[WARN]  k3s is not running yet."
    sleep 1
  done
}

{
wait_for_k3s

case ${COMPONENT} in
  agent)
    kubectl apply -f /stackable-scripts/spec/repository.yaml
    kubectl apply -f /stackable-scripts/cr/repository.yaml
    /stackable-scripts/approve-cert-request.sh
    ;;
esac
}
