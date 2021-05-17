#!/bin/bash

kubectl get crds repositories.stable.stackable.de || kubectl apply -f /stackable-scripts/spec/repository.yaml
