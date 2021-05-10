

## Prerequisites

* All Stackable repos are checked out under the same root.
* The host (development) machine has /sys/fs/cgroups

## Debian/Centos image

    ./build.sh [debian|centos]

This builds the image stackabletech/<os-name>-devel-base.

## Test/Dev cycle

Start the container. This is only necessary once per test/dev session.

    ./init.sh [debian|centos]

Start the agent

    ./run.sh [debian|centos] /root/run-agent.sh

Start the integration tests

    ./run.sh [debian|centos] /root/test-agent.sh

## TODO:

* Try to run the container as non-root to avoid polluting the development source tree wit root-folders wen building the software.
* Add support for different OS versions (debian 10, 11, etc.)
* Maybe stop the agent after the tests conclude.
* Many more things ...

