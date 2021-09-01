#!/bin/bash


OPERATOR_NAME=${1:-zookeeper-operator}
OPERATOR_PACKAGE_NAME="stackable-${OPERATOR_NAME}-server"

export KUBECONFIG=/rancher/k3s.yml

set -e

[ -d /var/log/stackable/servicelogs ] || mkdir -p /var/log/stackable/servicelogs
exec >> /var/log/stackable/servicelogs/testmessages
exec 2>&1

install_package() {

  [ -f /etc/os-release ] && . /etc/os-release

  case $ID in
    debian)
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 16dd12f5c7a6d76a
      echo deb https://repo.stackable.tech/repository/deb-dev buster main | tee  /etc/apt/sources.list.d/stackable.list
      apt-get update -o Dir::Etc::sourcelist="sources.list.d/stackable.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
      apt-get install -y ${OPERATOR_PACKAGE_NAME}
      ;;
    centos)
      # TODO: maybe add the gpg key here too
      yum-config-manager --add-repo=https://repo.stackable.tech/repository/rpm-dev/el${VERSION}/
      yum --disablerepo="*" --enablerepo="repo.stackable.*" update
      yum install -y ${OPERATOR_PACKAGE_NAME} --nogpgcheck
      ;;
    *)
      echo "[ERROR] Operating system ($ID) not supported. Cannot install operator ${OPERATOR_PACKAGE_NAME}."
      exit 1
      ;;
  esac
}

install_service_environment() {
  #--------------------
  # Add KUBECONFIG to the service environment
  #--------------------
  [ -d /etc/systemd/system/${OPERATOR_PACKAGE_NAME}.service.d ] || mkdir -p /etc/systemd/system/${OPERATOR_PACKAGE_NAME}.service.d

  tee /etc/systemd/system/${OPERATOR_PACKAGE_NAME}.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="KUBECONFIG=/rancher/k3s.yml"
EOF
}

create_k8s_service() {
    kubectl apply -f /etc/stackable/${OPERATOR_NAME}/crd
    kubectl apply -f /provision/cr/${OPERATOR_NAME}-cluster.yaml
}

#--------------------
# main
#--------------------
{
  install_package
  install_service_environment
  create_k8s_service
  systemctl daemon-reload
  systemctl start ${OPERATOR_PACKAGE_NAME}
}
