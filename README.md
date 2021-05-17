This repository contains a collection of scripts that help developers of Stackable components (agent, operators, etc.) to
perform integration tests locally. For this purpose it sets up several Docker containers.

## Prerequisites

* All Stackable repos that are to be tested are checked out under the same root.
* The host (development) machine has /sys/fs/cgroups
* Use docker version >= 20 and docker-compose version >= 1.29

## K3S image

    ./build.sh k3s

This builds `stackabletech/k3s`.

The kubernetes control plane has its own image based on debian. This is because there are far too many issues
with running k3s in centos containers OOTB.

## Debian/Centos image

    ./build.sh [debian|centos7|centos8]

This builds the image `stackabletech/<os-name>-devel-base`.

# The agent

Use the scripts below to dev/test the agent.

## Test/Dev cycle

Start the container. This is only necessary once per test/dev session.

    ./init.sh [debian|centos7|centos8]

Start the agent

    ./run.sh run-agent

Start the integration tests

    ./run.sh test-agent

# The XXX operator

Here XXX can be replaced in the future with spark, zookeeper, etc.

Start the cluster:

    ./init.sh [debian|centos7|centos8] xxx-operator

Start the integration tests

    ./run.sh test-xxx-operator

# Teardown

  ./clean.sh [debian|centos7|centos8]

Stops containers and deletes temporary files.

## Known issues

* None of this stuff works on fedora 34 because of issues related to `cgroups v2`. 

