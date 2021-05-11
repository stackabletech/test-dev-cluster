FROM debian:buster

# Needed to run "source" command below, which is not available in plain "sh".
SHELL ["/bin/bash", "-c"]

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y vim procps curl gcc make pkg-config liblzma-dev libssl-dev libsystemd-dev python3-pip \
 && apt-get install -y --no-install-recommends \
        systemd      \
        systemd-sysv 

RUN apt-get clean \
&& rm -rf                     \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log

# Install required Python-Libs
RUN pip3 install PyYAML

#------------------------------------------------------------------------------
# Configure systemd.
#------------------------------------------------------------------------------
RUN systemctl mask --   \
     dev-hugepages.mount \
     sys-fs-fuse-connections.mount

# Tell systemd that ut's running in docker
ENV container docker

# Systemd responds to this when shutting down
STOPSIGNAL SIGRTMIN+3

# The host's cgroup filesystem need to be mounted (read-only) in the container.
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]

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
 && cargo install cargo-deb \
 && rustup toolchain install stable \
 && rustup default stable


#------------------------------------------------------------------------------
# Install k3s
#------------------------------------------------------------------------------
WORKDIR /k3s-install

# A slightly modified version of the official script available at https://get.k3s.io
# that doesn't try to verify for systemd.
COPY k3s/k3s-install.sh .

ENV INSTALL_K3S_SKIP_ENABLE=true
#
#  --bind-address debian_agent_1
#     Needed because with "localhost", k3s still binds to 127.1 which is not usable in a docker swarm (compose).
#
RUN /k3s-install/k3s-install.sh \
  --bind-address debian_agent_1 \
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

CMD ["/sbin/init"] 

