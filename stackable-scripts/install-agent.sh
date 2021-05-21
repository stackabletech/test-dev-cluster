#!/bin/bash

set -e

[ -d /var/log/stackable/servicelogs ] || mkdir -p /var/log/stackable/servicelogs
exec >> /var/log/stackable/servicelogs/testmessages
exec 2>&1

install_agent_package() {

  [ -f /etc/os-release ] && . /etc/os-release

  case $ID in
    debian)
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16dd12f5c7a6d76a
      echo deb https://repo.stackable.tech/repository/deb-release buster main | tee  /etc/apt/sources.list.d/stackable.list
      apt-get update -o Dir::Etc::sourcelist="sources.list.d/stackable.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
      apt-get install -y stackable-agent
      ;;
    centos)
      # TODO: maybe add the gpg key here too
      yum-config-manager --add-repo=https://repo.stackable.tech/repository/rpm-release/el${VERSION}/
      yum --disablerepo="*" --enablerepo="repo.stackable.*" update
      yum install -y stackable-agent --nogpgcheck
      ;;
    *)
      echo [ERROR] Don\'t know how to install the stackable agent on this system.
      exit 1
      ;;
  esac
}

install_service_environment() {
  #--------------------
  # Add KUBECONFIG to the service environment
  #--------------------
  [ -d /etc/systemd/system/stackable-agent.service.d ] || mkdir -p /etc/systemd/system/stackable-agent.service.d

  tee /etc/systemd/system/stackable-agent.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
EOF
}

#--------------------
# main
#--------------------
{
  install_agent_package
  install_service_environment
  systemctl start stackable-agent
}

