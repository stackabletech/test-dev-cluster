#!/bin/bash

systemctl enable k3s
systemctl start k3s

sleep 5

cat <<EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: repositories.stable.stackable.de
spec:
  group: stable.stackable.de
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                repo_type:
                  type: string
                properties:
                  type: object
                  additionalProperties:
                    type: string
  scope: Namespaced
  names:
    plural: repositories
    singular: repository
    kind: Repository
    shortNames:
    - repo
EOF

