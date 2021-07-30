#!/usr/bin/env bash

NE_VERSION=1.2.0
NE_FILE_NAME=node_exporter-${NE_VERSION}.linux-amd64.tar.gz
DEST_FOLDER=node_exporter-${NE_VERSION}.linux-amd64

if test ! -d ${DEST_FOLDER}; then
	curl -L https://github.com/prometheus/node_exporter/releases/download/v${NE_VERSION}/${NE_FILE_NAME} -o ${NE_FILE_NAME}
	tar xvfz ${NE_FILE_NAME}
fi

${DEST_FOLDER}/node_exporter --web.disable-exporter-metrics --web.listen-address=0.0.0.0:9100


