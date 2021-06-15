
# --- helper functions for logs ---
info()
{
    echo '[INFO] ' "$@"
}
warn()
{
    echo '[WARN] ' "$@" >&2
  }
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}

prepare_install_kubeconfig() {
  local HOSTNAME=$(hostname)
  docker exec -t k3s cat /etc/rancher/k3s/k3s.yaml | sed "s/k3s:6443/$HOSTNAME:6443/" > k3s.yaml
  info To use kubectl or k9s from the host system, you need to export KUBECONFIG in this terminal:
  info export KUBECONFIG=$(pwd)/k3s.yaml
}
