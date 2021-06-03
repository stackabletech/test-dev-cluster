This repository contains a collection of scripts that help developers of Stackable components (agent, operators, etc.) to
perform integration tests locally. For this purpose it sets up several Docker containers.

## Prerequisites

* All Stackable repos that are to be tested are checked out under the same root.
* The host (development) machine has /sys/fs/cgroups
* Use docker version >= 20 and docker-compose version >= 1.29

## Docker images

The required Docker images can be built using the script described in this section. As we host a `latest` version (built from the *main* branch) in our Docker repository, you might skip the building of the images if you do not require an individually built version.

### K3S image

    ./build.sh k3s

This builds `docker.stackable.tech/k3s`.

The kubernetes control plane has its own image based on debian. This is because there are far too many issues
with running k3s in centos containers OOTB.

### Debian/Centos image

    ./build.sh [debian|centos7|centos8]

This builds the image `docker.stackable.tech/<os-name>-devel-base`.

# The agent

Use the scripts below to dev/test the agent.

## Test/Dev cycle

Initialize the cluster.

    ./init.sh [debian|centos7|centos8] agent

 This is only necessary once per test/dev session. The `agent` and `agent-integration-test` repos are mounted in the root of the `agent` container.
 The `operator` container is started but it is not used.

Start the agent

    ./run.sh run-agent

Start the integration tests

    ./run.sh test-agent

# The XXX operator

Supported operator integration tests:
* Zookeeper
* Spark
* Kafka

In the future `nifi`, `hdfs`, etc. will be added to the list.

This assumes that you have `xxx-operator` and `xxx-oprerator-integration-tests` repositories checkout on your developmnent system. If any of those repositories are missing, this will not work. There are no sanity checks at the moment.

## Notes on the Kafka operator

When testing the Kafka operator by using `./init.sh debian kafka-operator` for example, an additional sidecar container is started. In this container, the nightly Zookeeper operator and a single node Zookeeper cluster are installed.

## Test/Dev cycle

Initialize the cluster.

    ./init.sh [debian|centos7|centos8] xxx-operator [docker-compose-options]

This is only necessary once per test/dev session. The `xxx-operator` repo is mounted in the root of the `operator` container. In the `agent` container, the latest version of the agent is installed from the appropriate repository. Also the Stackable Repository CRD is created and the `certificatesigningrequest` is approved so the agent is ready to go.

The third and following arguments are passed on to `docker-compose up`. For example:

  # start a cluster with three kubelets and zookeeper-operator integration tests
  ./init.sh debian zookeeper-operator --scale agent=3

Start the operator

    ./run.sh run-operator

Note that this commando is valid for all operators. It automatically finds which operator to run.

Start the integration tests

    ./run.sh test-operator

# Teardown

  ./clean.sh [debian|centos7|centos8]

Stops containers and deletes temporary files.

## Known issues

* None of this stuff works on fedora 34 because of issues related to `cgroups v2`. 

