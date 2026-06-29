#!/usr/bin/env bash
#
# install-cockpit.sh — run ON THE VPS as root/sudo.
# Installs Cockpit, configures it for Traefik at https://cockpit.bryanwills.dev
#
# Usage:
#   sudo ./install-cockpit.sh
#   sudo COCKPIT_FQDN=cockpit.bryanwills.dev ./install-cockpit.sh
#
set -euo pipefail

COCKPIT_FQDN="${COCKPIT_FQDN:-cockpit.bryanwills.dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)." >&2
  exit 1
fi

echo ">> Installing Cockpit..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y cockpit cockpit-podman 2>/dev/null || apt-get install -y cockpit

echo ">> Writing /etc/cockpit/cockpit.conf..."
mkdir -p /etc/cockpit
if [[ -f /etc/cockpit/cockpit.conf ]]; then
  cp -a /etc/cockpit/cockpit.conf "/etc/cockpit/cockpit.conf.bak.$(date +%Y%m%d-%H%M%S)"
fi
cat > /etc/cockpit/cockpit.conf <<EOF
[WebService]
Origins = https://${COCKPIT_FQDN} wss://${COCKPIT_FQDN}
ProtocolHeader = X-Forwarded-Proto
ForwardedForHeader = X-Forwarded-For
AllowUnencrypted = true
EOF

echo ">> Enabling cockpit.socket..."
systemctl enable --now cockpit.socket
systemctl restart cockpit.socket

echo
echo "Cockpit listens on :9090."
echo "Traefik route: https://${COCKPIT_FQDN} (file provider in traefik/dynamic/)"
echo "Ensure DNS points ${COCKPIT_FQDN} at this server, then browse there."
