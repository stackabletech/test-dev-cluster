ARG OS_VERSION=7
FROM centos:$OS_VERSION
ARG OS_VERSION # without this, the arg is not available after a FROM statement. See: https://stackoverflow.com/a/56748289

COPY centos/kubernetes.repo  /etc/yum.repos.d/kubernetes.repo

#------------------------------------------------------------------------------
# Install prerequisites
#------------------------------------------------------------------------------
RUN yum -y update \
    && yum install -y yum-utils curl gcc make pkg-config openssl-devel systemd-devel \
    kubectl vim java-11-openjdk python39 rpm-build jq
 
#------------------------------------------------------------------------------
# Make python3 the default python
#------------------------------------------------------------------------------

RUN if [ "8" == "$OS_VERSION" ]; then alternatives --set python /usr/bin/python3; fi

#------------------------------------------------------------------------------
# Install k9s
#------------------------------------------------------------------------------
RUN curl -L https://github.com/derailed/k9s/releases/download/v0.24.15/k9s_Linux_x86_64.tar.gz | tar -xzC /usr/local/bin


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
 && rustup toolchain install stable \
 && rustup default stable


#------------------------------------------------------------------------------
# Set KUBECONFIG
#------------------------------------------------------------------------------
ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CMD ["/usr/sbin/init"] 

