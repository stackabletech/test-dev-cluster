This repository contains a collection of scripts that help developers of Stackable components (agent, operators, etc.) to
perform integration tests locally. For this purpose it sets up several Docker containers.

## Prerequisites

* All Stackable repos are checked out under the same root.
* The host (development) machine has /sys/fs/cgroups
* Use docker version >= 20 and docker-compose version >= 1.29
* Do not run `init.sh` in a terminal multiplexer (tmux or screen) because this interferes with systemd in the container.


## Debian/Centos image

    ./build.sh [debian|centos7|centos8]

This builds the image stackabletech/<os-name>-devel-base.

# The agent

Use the scripts below to dev/test the agent.

## Test/Dev cycle

Start the container. This is only necessary once per test/dev session.

    ./init.sh [debian|centos7|centos8]

Start the agent

    ./run.sh [debian|centos7|centos8] /stackable-scripts/run-agent.sh

Start the integration tests

    ./run.sh [debian|centos7|centos8] /stackable-scripts/test-agent.sh

# The Spark operator

  ./run-spark-operator.sh

It sets up two containers with docker compose and actually runs the operator in one of them. No actual testing is being done currently. 

# Cleanup

  ./clean.sh [debian|centos7|centos8]

Stops containers and deletes temporary files.

