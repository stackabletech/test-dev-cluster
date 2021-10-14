#!/usr/bin/env bash

install_debian_packages() {
  #------------------------------------------------------------------------------
  # Install prerequisites
  #------------------------------------------------------------------------------
  apt-get update \
  && apt-get install -y \
  apt-utils procps curl build-essential pkg-config liblzma-dev libssl-dev libsystemd-dev \
  systemd systemd-sysv apt-transport-https ca-certificates vim openjdk-11-jre python3

  #------------------------------------------------------------------------------
  # Make python3 the default python
  #------------------------------------------------------------------------------
  update-alternatives --install /usr/bin/python python /usr/bin/python3 1

  #------------------------------------------------------------------------------
  # Add K8S repository for kubectl
  #------------------------------------------------------------------------------
  curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

  apt-get update -o Dir::Etc::sourcelist="sources.list.d/kubernetes.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" \
  && apt-get install -y kubectl

  apt-get clean \
  && rm -rf                     \
      /var/lib/apt/lists/*          \
      /var/log/alternatives.log     \
      /var/log/apt/history.log      \
      /var/log/apt/term.log         \
      /var/log/dpkg.log

  #------------------------------------------------------------------------------
  # Stackable user
  #------------------------------------------------------------------------------
  addgroup stackable \
    && adduser --system --disabled-password --ingroup stackable stackable

  echo "export KUBECONFIG=/rancher/k3s.yml" >> /etc/bash.bashrc
}

install_centos_packages() {
  #------------------------------------------------------------------------------
  # Add K8S repository for kubectl
  #------------------------------------------------------------------------------
  cp /provision/centos/kubernetes.repo  /etc/yum.repos.d/kubernetes.repo

  #------------------------------------------------------------------------------
  # Install prerequisites
  #------------------------------------------------------------------------------
  yum -y update \
      && yum install -y yum-utils curl gcc make pkg-config openssl-devel systemd-devel \
      kubectl vim java-11-openjdk python3 rpm-build jq python39
 
  #------------------------------------------------------------------------------
  # Make python3 the default python
  #------------------------------------------------------------------------------
  alternatives --set python /usr/bin/python3.9
  alternatives --set python3 /usr/bin/python3.9

  #------------------------------------------------------------------------------
  # Stackable user
  #------------------------------------------------------------------------------
  useradd --system --user-group stackable

  echo "export KUBECONFIG=/rancher/k3s.yml" > /etc/profile.d/kubeconfig.sh
}

function install_k9s() {
  curl -L https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz | tar -xzC /usr/local/bin
}

#------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------
{
  [ -f /etc/os-release ] && . /etc/os-release

  install_k9s

  case $ID in
    debian)
      install_debian_packages
    ;;
    centos)
      install_centos_packages
    ;;
  esac
}
