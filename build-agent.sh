#!/bin/bash

docker run --rm -i -v $HOME/dev/projects/agent/:/builddir/ stackable-dev-test /builddir/build.sh
#docker run --rm -i -v $HOME/dev/projects/agent/:/builddir/ stackable-dev-test "cd /builddir && cargo build --verbose"
# worked fine docker run --rm -it -v $HOME/dev/projects/agent/:/builddir/ stackable-dev-test /bin/bash