#!/usr/bin/env bash
set +x

CONTAINER_OS_NAME=$1
NODE_NAME=$2
NODE_ID=$3

export KUBECONFIG=/rancher/k3s-${CONTAINER_OS_NAME}.yml

wait_for_k3s() {
  until kubectl get crds >/dev/null 2>&1; do
    >&2 echo "[WARN]  k3s is not running yet."
    sleep 1
  done
}

install_crds() {
  wait_for_k3s

  kubectl apply -f /provision/spec/repository.yaml
  kubectl apply -f /provision/cr/repository.yaml
}

approve_cert_request() {
  local TTL_SECONDS=${1:-10}
  local SLEEP_SECONDS=2
  local LOOP_COUNT=$(($TTL_SECONDS / $SLEEP_SECONDS))

  for i in $(seq 1 ${LOOP_COUNT}); do
    sleep ${SLEEP_SECONDS}
    for CERT_SIGN_REQUEST in $(kubectl get certificatesigningrequests | awk '/Pending/ {print $1}'); do
      kubectl certificate approve ${CERT_SIGN_REQUEST}
    done
  done
}

label_k8s_node() {
  kubectl label node --overwrite ${NODE_NAME} node=${NODE_ID}
}

#--------------------
# main
#--------------------
{
  install_crds
  systemctl start stackable-agent
  approve_cert_request
  label_k8s_node
}

