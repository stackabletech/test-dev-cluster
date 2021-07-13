#!/bin/bash

VMETRICS_VERSION="v1.62.0"
VMETRICS_URL="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/${VMETRICS_VERSION}/victoria-metrics-amd64-${VMETRICS_VERSION}.tar.gz"
VMETRICS_INSTALL_DIR="/opt/stackable-monitoring"
VMETRICS_DATA_DIR="/var/lib/victoria-metrics-data"
VMETRICS_BIN_NAME="victoria-metrics-prod"

install_victoria_metrics() {
  mkdir -p ${VMETRICS_INSTALL_DIR}

  pushd ${VMETRICS_INSTALL_DIR}
  curl -L ${VMETRICS_URL} | tar xzf -
  popd
}

start_victoria_metrics() {
  ${VMETRICS_INSTALL_DIR}/${VMETRICS_BIN_NAME} -storageDataPath=${VMETRICS_DATA_DIR} -retentionPeriod=1h 
}

{
  install_victoria_metrics
}
