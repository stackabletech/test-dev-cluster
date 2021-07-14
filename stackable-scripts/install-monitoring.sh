#!/bin/bash

VMETRICS_VERSION="v1.62.0"
VMETRICS_URL="https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/${VMETRICS_VERSION}/victoria-metrics-amd64-${VMETRICS_VERSION}.tar.gz"
VMETRICS_INSTALL_DIR="/opt/stackable-monitoring"
VMETRICS_DATA_DIR="/var/lib/victoria-metrics-data"
VMETRICS_BIN_NAME="victoria-metrics-prod"

JMX_EXPORTER="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.0/jmx_prometheus_javaagent-0.16.0.jar"

install_victoria_metrics() {
  mkdir -p ${VMETRICS_INSTALL_DIR}

  pushd ${VMETRICS_INSTALL_DIR}
  curl -L ${VMETRICS_URL} | tar xzf -
  curl -L ${JMX_EXPORTER} -o jmx_prometheus_javaagent-0.16.0.jar
  cat <<EOF > config.yaml
---
rules:
  - pattern: "metrics<name=master\\\\.(.*), type=counters><>Value"
    name: spark_master_\$1
EOF

  cat <<EOF1 > test-cluster.yaml
---
apiVersion: spark.stackable.tech/v1
kind: SparkCluster
metadata:
  name: simple
spec:
  version: "3.0.1"
  masters:
    selectors:
      default:
        selector:
          matchLabels:
            kubernetes.io/arch: stackable-linux
        instances: 1
        instancesPerNode: 1
        config:
          masterPort: 7078
          masterWebUiPort: 8081
  workers:
    selectors:
      1core1g:
        selector:
          matchLabels:
            kubernetes.io/arch: stackable-linux
        instances: 1
        instancesPerNode: 1
        config:
          workerPort: 3031
          workerWebUiPort: 8083
EOF1

  cat <<EOF2 > prometheus.yaml
---
scrape_configs:
  - job_name: spark
    metrics_path: /metrics/master/prometheus
    scrape_interval: 5s
    scrape_timeout: 5s
    static_configs:
      - targets:
        - localhost:8080
EOF2

  cat <<EOF3 > /opt/stackable/packages/spark-3.0.1/spark-3.0.1-bin-hadoop2.7/conf/metrics.properties
*.sink.console.class=org.apache.spark.metrics.sink.ConsoleSink
*.sink.console.period=5
*.sink.console.unit=seconds
EOF3

  popd

  export SPARK_MASTER_OPTS="-javaagent:/opt/stackable-monitoring/jmx_prometheus_javaagent-0.16.0.jar=9090:/opt/stackable-monitoring/config.yaml"
  export SERVER_JVMFLAGS="-javaagent:/home/malte/developer/stackable/test/apache-zookeeper-3.5.8-bin/conf/jmx_prometheus_javaagent-0.16.0.jar=9090:/home/malte/developer/stackable/test/apache-zookeeper-3.5.8-bin/conf/config.yaml"
  # /opt/stackable/packages/spark-3.0.1/spark-3.0.1-bin-hadoop2.7/sbin/start-master.sh
  # . /stackable-scripts/install-monitoring.sh
}

start_victoria_metrics() {
  ${VMETRICS_INSTALL_DIR}/${VMETRICS_BIN_NAME} -storageDataPath=${VMETRICS_DATA_DIR} -retentionPeriod=1h -promscrape.config=/opt/stackable-monitoring/prometheus.yaml -promscrape.config.strictParse=true
}

{
  install_victoria_metrics
}
