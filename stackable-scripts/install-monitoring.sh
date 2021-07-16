#!/bin/bash

VMETRICS_VERSION="v1.62.0"
VMETRICS_URL="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/${VMETRICS_VERSION}/victoria-metrics-amd64-${VMETRICS_VERSION}.tar.gz"
VMETRICS_INSTALL_DIR="/opt/stackable-monitoring"
VMETRICS_DATA_DIR="/var/lib/victoria-metrics-data"
VMETRICS_BIN_NAME="victoria-metrics-prod"

PROM_URL="https://github.com/prometheus/prometheus/releases/download/v2.28.1/prometheus-2.28.1.linux-amd64.tar.gz"
PROM_BIN_NAME="prometheus"

JMX_EXPORTER_URL="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.0/jmx_prometheus_javaagent-0.16.0.jar"
JMX_EXPORTER_BIN_NAME="jmx_prometheus_javaagent-0.16.0.jar"

install_victoria_metrics() {
  mkdir -p ${VMETRICS_INSTALL_DIR}

  pushd ${VMETRICS_INSTALL_DIR}
  if [ ! -f "$VMETRICS_BIN_NAME" ]; then
    curl -L ${VMETRICS_URL} | tar xzf -
  fi

  if [ ! -f "$JMX_EXPORTER_BIN_NAME" ]; then
    curl -L ${JMX_EXPORTER_URL} -o ${JMX_EXPORTER_BIN_NAME}
  fi

  if [ ! -f "prometheus-2.28.1.linux-amd64/$PROM_BIN_NAME" ]; then
    curl -L ${PROM_URL} | tar xzf -
  fi

  cat <<EOF > config.yaml
---
rules:
  # replicated Zookeeper
  - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\\\d+)><>(\\\\w+)"
    name: "zookeeper_\$2"
    type: GAUGE
  # standalone Zookeeper
  - pattern: "org.apache.ZooKeeperService<name0=StandaloneServer_port(\\\\d+)><>(\\\\w+)"
    type: GAUGE
    name: "zookeeper_\$2"
EOF

  cat <<EOF1 > test-cluster.yaml
---
apiVersion: zookeeper.stackable.tech/v1
kind: ZookeeperCluster
metadata:
  name: simple
spec:
  version: 3.5.8
  servers:
    selectors:
      default:
        selector:
          matchLabels:
            kubernetes.io/arch: stackable-linux
        instances: 1
        instancesPerNode: 1
EOF1

#  cat <<EOF2 > prometheus.yaml
#---
#scrape_configs:
#  - job_name: spark
#    metrics_path: /metrics/master/prometheus
#    scrape_interval: 5s
#    scrape_timeout: 5s
#    static_configs:
#      - targets:
#        - localhost:8080
#EOF2

#  cat <<EOF3 > /opt/stackable/packages/spark-3.0.1/spark-3.0.1-bin-hadoop2.7/conf/metrics.properties
#*.sink.console.class=org.apache.spark.metrics.sink.ConsoleSink
#*.sink.console.period=5
#*.sink.console.unit=seconds
#EOF3

  popd

  #export SPARK_MASTER_OPTS="-javaagent:/opt/stackable-monitoring/jmx_prometheus_javaagent-0.16.0.jar=9090:/opt/stackable-monitoring/config.yaml"
  #export SERVER_JVMFLAGS="-javaagent:/home/malte/developer/stackable/test/apache-zookeeper-3.5.8-bin/conf/jmx_prometheus_javaagent-0.16.0.jar=9404:/home/malte/developer/stackable/test/apache-zookeeper-3.5.8-bin/conf/config.yaml"
  # /opt/stackable/packages/spark-3.0.1/spark-3.0.1-bin-hadoop2.7/sbin/start-master.sh
  # . /stackable-scripts/install-monitoring.sh
}

start_victoria_metrics() {
  ${VMETRICS_INSTALL_DIR}/${VMETRICS_BIN_NAME} -storageDataPath=${VMETRICS_DATA_DIR} -retentionPeriod=1h -promscrape.config=/stackable-scripts/prometheus.yaml -promscrape.config.strictParse=true
  #./victoria-metrics-prod -storageDataPath=/tmp/victoria -retentionPeriod=1h -promscrape.config=/home/malte/developer/workspace/test-dev-cluster/stackable-scripts/prometheus.yaml -promscrape.config.strictParse=true
}

start_prom_metrics() {
  ${VMETRICS_INSTALL_DIR}/prometheus-2.28.1.linux-amd64/${PROM_BIN_NAME} --log.level debug --config.file=/stackable-scripts/prometheus.yaml
}

{
  install_victoria_metrics
}
