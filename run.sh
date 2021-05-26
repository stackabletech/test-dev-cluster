#!/usr/bin/env sh

COMMAND=${1}
shift;

agent_container_name() {
  docker ps | awk '/agent/ {print $NF}'
}

{
case ${COMMAND} in
run-agent)
  docker exec -t $(agent_container_name) /stackable-scripts/run-agent.sh
  ;;
test-agent)
  docker exec -t $(agent_container_name) /stackable-scripts/test-agent.sh $@
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
}
