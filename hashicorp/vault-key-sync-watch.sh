#!/usr/bin/env bash
# =============================================================================
# vault-key-sync-watch.sh
# Triggered by launchd WatchPaths when ~/.keys changes.
# Syncs only NEW keys to Vault; skips anything already uploaded.
#
# Install:
#   See README-KEYS-STRUCTURE.md → "Auto-sync on macOS" section
#   or run: bash vault-key-sync-watch.sh --install
#
# Manual run:
#   bash ~/vault-key-sync-watch.sh
# =============================================================================

set -uo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
KEYS_DIR="${KEYS_DIR:-${HOME}/.keys}"
VAULT_ADDR="${VAULT_ADDR:-https://keys.bryanwills.dev}"
SYNC_SCRIPT="${HOME}/export-keys-to-vault.sh"
LOG_FILE="${HOME}/Library/Logs/vault-key-sync.log"
LOCK_FILE="/tmp/vault-key-sync.lock"

# Device prefix — change to vps / work to namespace keys from other machines
DEVICE_PREFIX="${DEVICE_PREFIX:-macbook}"

# ── Colours ────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# ── Install helper ─────────────────────────────────────────────────────────
install_launchd() {
  local plist_src
  plist_src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dev.bryanwills.vault-key-sync.plist"
  local plist_dst="${HOME}/Library/LaunchAgents/dev.bryanwills.vault-key-sync.plist"

  if [[ ! -f "$plist_src" ]]; then
    echo -e "${RED}ERROR: Cannot find plist at ${plist_src}${NC}" >&2
    echo "Run this from the hashicorp/ directory after SCP-ing both files to ~/." >&2
    exit 1
  fi

  # Expand $HOME in plist before installing
  sed "s|__HOME__|${HOME}|g" "$plist_src" > "$plist_dst"

  # Unload any old version first
  launchctl unload "$plist_dst" 2>/dev/null || true
  launchctl load -w "$plist_dst"

  echo -e "${GREEN}✔ launchd agent installed and loaded.${NC}"
  echo "  Watch path : ${KEYS_DIR}"
  echo "  Log file   : ${LOG_FILE}"
  echo "  To uninstall: launchctl unload ${plist_dst} && rm ${plist_dst}"
}

if [[ "${1:-}" == "--install" ]]; then
  install_launchd
  exit 0
fi

# ── Lock: prevent overlapping runs ─────────────────────────────────────────
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [SKIP] Already running — exiting." >> "${LOG_FILE}"
  exit 0
fi

# ── Logging ────────────────────────────────────────────────────────────────
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG_FILE}"; }

mkdir -p "$(dirname "${LOG_FILE}")"
log "── Vault key sync triggered ──────────────────────────────────────"

# ── Check vault CLI is available ───────────────────────────────────────────
if ! command -v vault &>/dev/null; then
  log "ERROR: vault CLI not found in PATH. Install from https://developer.hashicorp.com/vault/install"
  exit 1
fi

# ── Check sync script exists ───────────────────────────────────────────────
if [[ ! -f "${SYNC_SCRIPT}" ]]; then
  log "ERROR: ${SYNC_SCRIPT} not found. SCP it from your VPS:"
  log "  scp bryanwi09@<vps-ip>:/home/bryanwi09/docker/hashicorp/export-keys-to-vault.sh ~/"
  exit 1
fi

# ── Authenticate check ─────────────────────────────────────────────────────
export VAULT_ADDR
if ! vault token lookup &>/dev/null; then
  log "WARN: Not authenticated to Vault. Run: vault login -method=github token=<PAT>"
  # Send a macOS notification so it is visible even when terminal is closed
  osascript -e 'display notification "vault-key-sync: Not authenticated — run vault login" with title "Vault Key Sync"' 2>/dev/null || true
  exit 1
fi

# ── Small debounce: wait a moment for writes to settle ─────────────────────
sleep 2

# ── Run sync ───────────────────────────────────────────────────────────────
log "Syncing ${KEYS_DIR} → ${VAULT_ADDR} (prefix: ${DEVICE_PREFIX}, mode: new-only)"

bash "${SYNC_SCRIPT}" \
  --keys-dir="${KEYS_DIR}" \
  --vault-addr="${VAULT_ADDR}" \
  --device-prefix="${DEVICE_PREFIX}" \
  --mode=new-only \
  >> "${LOG_FILE}" 2>&1

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  log "Sync completed successfully."
  osascript -e 'display notification "New keys synced to Vault" with title "Vault Key Sync"' 2>/dev/null || true
else
  log "Sync exited with code ${EXIT_CODE} — check log above for details."
  osascript -e 'display notification "vault-key-sync: sync failed — check ~/Library/Logs/vault-key-sync.log" with title "Vault Key Sync"' 2>/dev/null || true
fi

log "────────────────────────────────────────────────────────────────"
exit $EXIT_CODE
