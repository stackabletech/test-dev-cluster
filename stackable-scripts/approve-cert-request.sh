#!/bin/bash

while true; do
  CERT_SIGN_REQUEST=$(kubectl get certificatesigningrequests | grep -i pending | awk '{print $1}')
  if [ "${CERT_SIGN_REQUEST}" != "" ]; then
    kubectl certificate approve ${CERT_SIGN_REQUEST}
    exit 0
  else
    sleep 5
  fi
done

