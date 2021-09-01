# Vagrant and VMs

## Requirements

* VirtualBox (see Issues below)
* Vagrant

## Usage

    # start a cluster
    ./init.sh debian kafka-operator

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


## operator VM

* cargo is installed under /root/.cargo
* become `root` to build and run operators and tests:

    vagrant ssh operator
    sudo su -
* operator source is mounted under /
* operator tests source is also mounted under /

## k3s VM

Started with all optional features disabled.

The `rancher` sub-folder is mounted on all vms and contains the K8S configuration file that is exported by `k3s` at provisioning time.

## Issues

### VirtualBox and secure boot

Systems with secure boot enabled cannt load VirtualBox drivers because they are not signed. Possible solutions are:
* sign drivers (how?)
* disable secure boot


