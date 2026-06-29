#!/usr/bin/env bash
#
# extract-services.sh
# -----------------------------------------------------------------------------
# Inventories running Docker containers on the current host and prints:
#   1. A human-readable table: container | networks | Traefik Host rule | port
#   2. The list of Docker networks (so you know what to put in compose files)
#   3. A ready-to-paste Homepage services.yaml snippet
#
# Works on any host with Docker. Read-only: it never changes anything.
#
# Usage:
#   ./extract-services.sh                # table + networks + yaml to stdout
#   ./extract-services.sh > inventory.txt
#   ./extract-services.sh --yaml-only    # only the services.yaml snippet
#
# Requires: docker. `jq` is optional (used for nicer parsing if present).
# -----------------------------------------------------------------------------
set -euo pipefail

YAML_ONLY=0
[[ "${1:-}" == "--yaml-only" ]] && YAML_ONLY=1

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found on PATH" >&2
  exit 1
fi

# Pull the first "Host(\`...\`)" hostname out of a container's Traefik labels.
get_host() {
  local c="$1"
  docker inspect "$c" \
    --format '{{range $k,$v := .Config.Labels}}{{if and (gt (len $k) 19) (eq (slice $k 0 19) "traefik.http.router")}}{{$v}}{{"\n"}}{{end}}{{end}}' \
    2>/dev/null \
    | grep -oE 'Host\(`[^`]+`\)' \
    | head -n1 \
    | sed -E 's/Host\(`([^`]+)`\)/\1/' || true
}

# Pull the Traefik loadbalancer server port label, if present.
get_port() {
  local c="$1"
  docker inspect "$c" \
    --format '{{range $k,$v := .Config.Labels}}{{if (eq $k "traefik.http.services.'"$c"'.loadbalancer.server.port")}}{{$v}}{{end}}{{end}}' \
    2>/dev/null || true
}

get_networks() {
  local c="$1"
  docker inspect "$c" \
    --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null || true
}

containers="$(docker ps --format '{{.Names}}' | sort)"

if [[ "$YAML_ONLY" -eq 0 ]]; then
  echo "=================================================================="
  echo " DOCKER NETWORKS ON THIS HOST"
  echo "=================================================================="
  docker network ls --format 'table {{.Name}}\t{{.Driver}}\t{{.Scope}}'
  echo
  echo "=================================================================="
  echo " CONTAINER INVENTORY"
  echo "=================================================================="
  printf '%-26s %-28s %-32s %s\n' "CONTAINER" "NETWORKS" "TRAEFIK HOST" "PORT"
  printf '%-26s %-28s %-32s %s\n' "---------" "--------" "------------" "----"
  while read -r c; do
    [[ -z "$c" ]] && continue
    printf '%-26s %-28s %-32s %s\n' \
      "$c" "$(get_networks "$c")" "$(get_host "$c")" "$(get_port "$c")"
  done <<< "$containers"
  echo
fi

echo "=================================================================="
echo " HOMEPAGE services.yaml SNIPPET (review hostnames before pasting)"
echo "=================================================================="
echo "- Auto-generated:"
while read -r c; do
  [[ -z "$c" ]] && continue
  host="$(get_host "$c")"
  echo "    - ${c}:"
  if [[ -n "$host" ]]; then
    echo "        href: https://${host}"
  fi
  echo "        icon: ${c}.png"
  echo "        server: my-docker"
  echo "        container: ${c}"
done <<< "$containers"
