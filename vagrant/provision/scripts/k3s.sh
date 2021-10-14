#!/usr/bin/env bash

CONTAINER_OS_NAME=$1
IP=$2

#  --bind-address 192.168.33.10 \
#  --node-external-ip 192.168.33.10 \

curl -sfL https://get.k3s.io | sh -s - \
  --bind-address ${IP} \
  --node-external-ip ${IP} \
  --disable coredns \
  --disable servicelb \
  --disable traefik \
  --disable local-storage \
  --disable metrics-server \
  --disable-cloud-controller \
  --disable-network-policy \
  --write-kubeconfig /rancher/k3s-${CONTAINER_OS_NAME}.yml \
  --kube-controller-manager-arg cluster-signing-cert-file= \
  --kube-controller-manager-arg cluster-signing-key-file= \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-cert-file=/var/lib/rancher/k3s/server/tls/server-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-key-file=/var/lib/rancher/k3s/server/tls/server-ca.key


