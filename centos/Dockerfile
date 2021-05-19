ARG OS_VERSION
FROM centos:$OS_VERSION

COPY centos/kubernetes.repo  /etc/yum.repos.d/kubernetes.repo

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN yum -y update \
 && yum install -y yum-utils curl gcc make pkg-config openssl-devel systemd-devel kubectl vim
 
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
 && . $HOME/.cargo/env \
 && rustup toolchain install nightly \
 && rustup default nightly


#------------------------------------------------------------------------------
# Set KUBECONFIG
#------------------------------------------------------------------------------
ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CMD ["/usr/sbin/init"] 

