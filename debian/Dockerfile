FROM debian:buster

# Needed to run "source" command below, which is not available in plain "sh".
#SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y \
 apt-utils procps curl build-essential pkg-config liblzma-dev libssl-dev libsystemd-dev \
 systemd systemd-sysv apt-transport-https ca-certificates vim openjdk-11-jre python3

#------------------------------------------------------------------------------
# Make python3 the default python
#------------------------------------------------------------------------------
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

#------------------------------------------------------------------------------
# Install k9s
#------------------------------------------------------------------------------
RUN curl -L https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz | tar -xzC /usr/local/bin

#------------------------------------------------------------------------------
# Add K8S repository for kubectl
#------------------------------------------------------------------------------
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update \
 && apt-get install -y kubectl

RUN apt-get clean \
&& rm -rf                     \
    /var/lib/apt/lists/*          \
    /var/log/alternatives.log     \
    /var/log/apt/history.log      \
    /var/log/apt/term.log         \
    /var/log/dpkg.log

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

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

#------------------------------------------------------------------------------
# Install Rust
#------------------------------------------------------------------------------
#RUN useradd -ms /bin/bash stackable
#USER stackable:stackable
#WORKDIR /home/stackable

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
 && . $HOME/.cargo/env \
 && cargo install cargo-deb \
 && rustup toolchain install stable \
 && rustup default stable

#USER root

#------------------------------------------------------------------------------
# Set KUBECONFIG
#------------------------------------------------------------------------------
ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#------------------------------------------------------------------------------
# Configure K8S repo
#------------------------------------------------------------------------------
ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CMD ["/sbin/init"] 




