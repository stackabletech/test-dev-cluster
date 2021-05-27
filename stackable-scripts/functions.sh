
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

