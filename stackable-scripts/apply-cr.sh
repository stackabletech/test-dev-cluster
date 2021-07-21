#!/bin/bash

CR_NAME=$1

case $CR_NAME in
    repository)
        kubectl apply -f /stackable-scripts/cr/repository.yaml
        ;;
    zookeeper-cluster)
      kubectl apply -f /stackable-scripts/cr/zookeeper-cluster.yaml
        # Get the host name of the first node (and remove the "node/" prefix from the kubectl output)
#        HOSTNAME=$(kubectl get nodes -o name | head -1 | awk '{host=substr($0, 6); print host}')
#        cat /stackable-scripts/cr/zookeeper-cluster.yaml | sed "s/{{HOSTNAME}}/$HOSTNAME/g" | kubectl apply -f -
        ;;
    monitoring-cluster)
      kubectl apply -f /stackable-scripts/cr/monitoring-cluster.yaml
        ;;
esac

