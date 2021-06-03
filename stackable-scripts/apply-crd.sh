#!/bin/bash

SPEC_NAME=$1

case ${SPEC_NAME} in
    repository)
        kubectl get crds repositories.stable.stackable.de || kubectl apply -f /stackable-scripts/spec/repository.yaml
        ;;
    zookeeper-cluster)
        kubectl get crds zookeeperclusters.zookeeper.stackable.tech  || kubectl apply -f /stackable-scripts/spec/zookeeper-cluster.yaml
        ;;
esac
