This repository contains a collection of scripts that help developers of Stackable components (agent, operators, etc.) to
perform integration tests locally. For this purpose it sets up several Docker containers.

## Prerequisites

* All Stackable repos are checked out under the same root.
* The host (development) machine has /sys/fs/cgroups

## Debian/Centos image

    ./build.sh [debian|centos]

This builds the image stackabletech/<os-name>-devel-base.

# The agent

Use the scripts below to dev/test the agent.

## Test/Dev cycle

Start the container. This is only necessary once per test/dev session.

    ./init.sh [debian|centos]

Start the agent

    ./run.sh [debian|centos] /root/run-agent.sh

Start the integration tests

    ./run.sh [debian|centos] /root/test-agent.sh

# The Spark operator

  ./run-spark-operator.sh

It sets up two containers with docker compose and actually runs the operator in one of them. No actual testing is being done currently. 
