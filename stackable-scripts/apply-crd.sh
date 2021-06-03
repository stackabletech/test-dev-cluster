#!/bin/bash

SPEC_NAME=$1

case ${SPEC_NAME} in
    repository)
        kubectl apply -f /stackable-scripts/spec/repository.yaml
        ;;
    zookeeper-cluster)
        kubectl apply -f /stackable-scripts/spec/zookeeper-cluster.yaml
        ;;
esac
