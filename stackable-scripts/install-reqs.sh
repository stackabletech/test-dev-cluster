#!/bin/bash

COMPONENT=$1

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

case ${COMPONENT} in
  agent)
    /stackable-scripts/apply-crd.sh repository
    /stackable-scripts/apply-cr.sh repository
    /stackable-scripts/approve-cert-request.sh
    ;;
  zookeeper-operator)
    /stackable-scripts/apply-crd.sh zookeeper-cluster
    /stackable-scripts/apply-cr.sh zookeeper-cluster
  ;;
esac
}