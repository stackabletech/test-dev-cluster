FROM centos:8

# Needed to run "source" command below, which is not available in plain "sh".
SHELL ["/bin/bash", "-c"]

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN yum -y update \
 && yum install -y vim procps curl gcc make dbus-devel pkg-config openssl-devel systemd-devel python3-pip \
 container-selinux selinux-policy-base

# Install required Python-Libs
RUN pip3 install PyYAML

#------------------------------------------------------------------------------
# Configure systemd.
#------------------------------------------------------------------------------
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Systemd responds to this when shutting down
STOPSIGNAL SIGRTMIN+3

VOLUME ["/sys/fs/cgroup"]

# Regenerate this in each container.
RUN rm -f           \
    /etc/machine-id \
    /var/lib/dbus/machine-id

#------------------------------------------------------------------------------
# Install Rust
#------------------------------------------------------------------------------
WORKDIR /root

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && source $HOME/.cargo/env \
 && rustup toolchain install stable \
 && rustup default stable


#------------------------------------------------------------------------------
# Install k3s
#------------------------------------------------------------------------------
WORKDIR /k3s-install

# A slightly modified version of the official script available at https://get.k3s.io
# that doesn't try to verify for systemd.
COPY k3s/k3s-install.sh .

ENV INSTALL_K3S_SKIP_ENABLE=true \
  INSTALL_K3S_SELINUX_WARN=true \
  INSTALL_K3S_SKIP_SELINUX_RPM=true
RUN /k3s-install/k3s-install.sh \
  --kube-controller-manager-arg cluster-signing-cert-file= \
  --kube-controller-manager-arg cluster-signing-key-file= \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kube-apiserver-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-client-cert-file=/var/lib/rancher/k3s/server/tls/client-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-client-key-file=/var/lib/rancher/k3s/server/tls/client-ca.key \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-cert-file=/var/lib/rancher/k3s/server/tls/server-ca.crt \
  --kube-controller-manager-arg cluster-signing-kubelet-serving-key-file=/var/lib/rancher/k3s/server/tls/server-ca.key

ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#------------------------------------------------------------------------------
# Install Stackable scripts
#------------------------------------------------------------------------------
WORKDIR /root

COPY stackable-scripts/*.sh ./

RUN mkdir -p /opt/stackable/packages \
  && mkdir -p /var/lib/stackable/stackable-agent \
  && mkdir -p /var/log/stackable/servicelogs \
  && mkdir -p /etc/stackable/stackable-agent \
  && mkdir -m 700 /etc/stackable/stackable-agent/secret

CMD ["/usr/sbin/init"] 

