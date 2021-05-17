#!/usr/bin/env sh

COMMAND=${1}

case ${COMMAND} in
run-agent)
  docker exec -t agent /stackable-scripts/run-agent.sh
  ;;
test-agent)
  docker exec -t agent /stackable-scripts/test-agent.sh
  ;;
*)
  echo ERROR: Unkown command.
esac