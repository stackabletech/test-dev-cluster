#!/usr/bin/env bash

apt-get update \
 && apt-get install -y \
    apt-utils \
    curl \
    systemd \
    systemd-sysv \
    linux-headers-$(uname -r) \
    build-essential \
    dkms

apt-get clean \
&& rm -rf                     \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log

curl -sfL https://get.k3s.io | sh -s - \
  --bind-address 192.168.33.10 \
  --disable coredns \
  --disable servicelb \
  --disable traefik \
  --disable local-storage \
  --disable metrics-server \
  --disable-cloud-controller \
  --disable-network-policy \
  --disable-scheduler \
  --write-kubeconfig /rancher/k3s.yml \
  --kube-controller-manager-arg cluster-signing-cert-file= \
  --kube-controller-manager-arg cluster-signing-key-file= \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-cert-file=/var/lib/rancher/k3s/server/tls/server-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-key-file=/var/lib/rancher/k3s/server/tls/server-ca.key


