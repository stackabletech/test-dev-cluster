# Vagrant and VMs

## Requirements

* VirtualBox (see Issues below)
* Vagrant

## Usage

    # start a cluster with 3 nodes
    ./init.sh debian10 kafka-operator 3

    # login into the operator VM and become root
    vagrant ssh operator
    sudo su -

    # run the kafka operator
    cd /kafka-operator && cargo run --verbose --target-dir /build/operator --bin stackable-kafka-operator-server

    # run the kafka operator integration tests
    cd /kafka-operator-integration-tests && cargo test --target-dir /build/tests -- --nocapture --test-threads=1 

    # stop the cluster
    ./clean.sh

    # destroy the cluster
    ./clean.sh destroy

    # suspend cluster
    ./clean.sh suspend


## agent VM

* the VMs are prefix with operating system name (to support multiple OSes running in parallel)
    vagrant ssh agent-debian10
* you can start multiple agent VMs with different OSes but the cleanup script will only clean up the last environment that was created
* cargo is installed under /root/.cargo and is in root's PATH
* become `root` to build and run operators and tests:

    sudo su -
    # run the agent
    cd /agent
    cargo run --target-dir /build/agent --bin stackable-agent

    # run the agent tests
    cd /agent-integration-tests
    cargo test --target-dir /build/agent-integration-tests

* agent source is mounted under /agent
* agent tests source is also mounted under /agent-integration-tests
* `kubectl` is confgured to use KUBECONFIG=/rancher/k3s.yml

## operator VM

* cargo is installed under /root/.cargo and is in root's PATH
* become `root` to build and run operators and tests:

    vagrant ssh operator
    sudo su -
* operator source is mounted under /xxx-operator
* operator tests source is also mounted under /xxx-operator-integration-tests
* `kubectl` is confgured to use KUBECONFIG=/rancher/k3s.yml

## k3s VM

Started with all optional features disabled.

The `rancher` sub-folder is mounted on all vms and contains the K8S configuration file that is exported by `k3s` at provisioning time.

## Issues

### VirtualBox and secure boot

Systems with secure boot enabled cannot load VirtualBox drivers because they are not signed. Possible solutions are:
* sign drivers (how?)
* disable secure boot


