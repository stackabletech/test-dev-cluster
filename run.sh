#!/usr/bin/env sh

COMMAND=${1}

case ${COMMAND} in
run-agent)
  docker exec -t agent /stackable-scripts/run-agent.sh
  ;;
test-agent)
  docker exec -t agent /stackable-scripts/test-agent.sh $@
  ;;
run-operator)
  docker exec -t operator /stackable-scripts/run-operator.sh
  ;;
test-operator)
  docker exec -t operator /stackable-scripts/test-operator.sh $@
  ;;
*)
  echo ERROR: Unkown command.
esac
