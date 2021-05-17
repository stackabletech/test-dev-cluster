FROM debian:buster

# Needed to run "source" command below, which is not available in plain "sh".
SHELL ["/bin/bash", "-c"]

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y vim procps curl gcc make pkg-config liblzma-dev libssl-dev libsystemd-dev \
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
 && source $HOME/.cargo/env \
 && cargo install cargo-deb \
 && rustup toolchain install stable \
 && rustup default stable

#USER root

#------------------------------------------------------------------------------
# Install k3s
#------------------------------------------------------------------------------
WORKDIR /k3s-install

# A slightly modified version of the official script available at https://get.k3s.io
# that doesn't try to verify for systemd.
COPY k3s/k3s-install.sh .

ENV INSTALL_K3S_SKIP_ENABLE=true

RUN /k3s-install/k3s-install.sh 

ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

#------------------------------------------------------------------------------
# Install Stackable scripts
#------------------------------------------------------------------------------
RUN mkdir -p /opt/stackable/packages \
  && mkdir -p /var/lib/stackable/stackable-agent \
  && mkdir -p /var/log/stackable/servicelogs \
  && mkdir -p /etc/stackable/stackable-agent \
  && mkdir -m 700 /etc/stackable/stackable-agent/secret

CMD ["/sbin/init"] 




