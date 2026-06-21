#!/usr/bin/env bash
#
# discover-hosts.sh (VPS variant)
# -----------------------------------------------------------------------------
# On the PUBLIC VPS a subnet scan is meaningless (the box sits on a shared /22
# public range), so "discovery" here = inventory the local Docker containers.
# It prints an Ansible inventory stub you can extend.
#
# For the WORK variant that scans a private subnet over SSH, see
# ~/work-containers/ansible/scripts/discover-hosts.sh
#
# Usage: ./discover-hosts.sh
# -----------------------------------------------------------------------------
set -euo pipefail

echo "# Auto-generated $(date -Is)"
echo "[local]"
echo "localhost ansible_connection=local"
echo
echo "# Docker containers currently running on this host (informational):"
if command -v docker >/dev/null 2>&1; then
  docker ps --format '#   {{.Names}}\t{{.Image}}\t{{.Status}}'
else
  echo "#   (docker not available)"
fi
