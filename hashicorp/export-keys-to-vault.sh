#!/usr/bin/env bash
# =============================================================================
# export-keys-to-vault.sh
# Sync ~/.keys (and subdirectories) into HashiCorp Vault KV v2.
#
# Usage:
#   ./export-keys-to-vault.sh [OPTIONS]
#
# Options:
#   --mode=new-only        (default) Import only files not yet in Vault
#   --mode=update          Import new files AND update changed existing ones
#   --mode=dry-run         Show what would be imported/updated without writing
#   --list                 List all local files and their Vault status then exit
#   --keys-dir=PATH        Override source directory (default: ~/.keys)
#   --vault-addr=URL       Override Vault address
#   --device-prefix=NAME   Namespace keys under keys/<NAME>/ (e.g. macbook, vps, work)
#
# Requirements:
#   - VAULT_TOKEN must be set (or logged in via `vault login`)
#   - `vault` CLI must be in PATH
#
# Vault path mapping:
#   ~/.keys/file             → secret/keys/file
#   ~/.keys/projects/app/x  → secret/keys/projects/app/x
#   ~/.keys/certs/ssl.pem   → secret/keys/certs/ssl_pem
#
# File type handling:
#   .pem .crt .key .asc .pub  → stored as text under field "content"
#   .yml .yaml .json          → stored as text; also stored under field "content"
#   .txt and dotfiles         → stored as text under field "content"
#   Binary/large files        → skipped with warning
# =============================================================================

set -uo pipefail

# ── defaults ──────────────────────────────────────────────────────────────────
KEYS_DIR="${HOME}/.keys"
VAULT_ADDR="${VAULT_ADDR:-https://keys.bryanwills.dev}"
VAULT_KV_PREFIX="keys"          # Vault path: secret/<VAULT_KV_PREFIX>/...
MODE="new-only"
LIST_ONLY=false
DEVICE_PREFIX=""                 # e.g. macbook, vps, work — namespaces keys by device

# ── colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── parse arguments ───────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --mode=*)            MODE="${arg#--mode=}" ;;
    --keys-dir=*)        KEYS_DIR="${arg#--keys-dir=}" ;;
    --vault-addr=*)      VAULT_ADDR="${arg#--vault-addr=}" ;;
    --device-prefix=*)   DEVICE_PREFIX="${arg#--device-prefix=}" ;;
    --list)              LIST_ONLY=true ;;
    --help|-h)
      sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo -e "${RED}Unknown argument: $arg${NC}"; exit 1 ;;
  esac
done

# If a device prefix is set, namespace all keys under keys/<prefix>/
if [[ -n "$DEVICE_PREFIX" ]]; then
  VAULT_KV_PREFIX="keys/${DEVICE_PREFIX}"
fi

export VAULT_ADDR

# ── validate ──────────────────────────────────────────────────────────────────
if [ ! -d "$KEYS_DIR" ]; then
  echo -e "${RED}❌  Keys directory not found: $KEYS_DIR${NC}"
  exit 1
fi

if ! command -v vault >/dev/null 2>&1; then
  echo -e "${RED}❌  vault CLI not found. Install it or run inside the vault container.${NC}"
  exit 1
fi

if ! vault token lookup >/dev/null 2>&1; then
  echo -e "${RED}❌  Not authenticated. Set VAULT_TOKEN or run: vault login${NC}"
  exit 1
fi

echo -e "${BOLD}${BLUE}🔑  Vault Key Sync${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Source  : ${CYAN}${KEYS_DIR}${NC}"
echo -e "  Vault   : ${CYAN}${VAULT_ADDR}${NC}"
echo -e "  Prefix  : ${CYAN}${VAULT_KV_PREFIX}${NC}"
echo -e "  Mode    : ${CYAN}${MODE}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# ── helpers ───────────────────────────────────────────────────────────────────

# Convert a local file path to its Vault KV path.
# ~/.keys/foo.txt                  → keys/foo_txt
# ~/.keys/projects/app/github      → keys/projects/app/github
# ~/.keys/certs/server.pem         → keys/certs/server_pem
file_to_vault_path() {
  local abs_path="$1"
  # Make relative to KEYS_DIR
  local rel="${abs_path#${KEYS_DIR}/}"
  # Strip leading dot from basename only (not path components)
  local dir
  local base
  dir="$(dirname "$rel")"
  base="$(basename "$rel")"
  base="${base#.}"               # strip leading dot (e.g. .env → env)
  base="${base//./_}"            # dots in filename → underscore (ssl.pem → ssl_pem)
  if [ "$dir" = "." ]; then
    echo "${VAULT_KV_PREFIX}/${base}"
  else
    echo "${VAULT_KV_PREFIX}/${dir}/${base}"
  fi
}

# Return 0 if file should be processed, 1 if it should be skipped.
is_processable() {
  local f="$1"
  local fname
  fname="$(basename "$f")"
  local size
  size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)

  # Skip files over 1 MB
  if [ "$size" -gt 1048576 ]; then
    echo -e "  ${YELLOW}⏭  Skipping (>1 MB): ${fname}${NC}"
    return 1
  fi

  # Skip known binary / archive extensions
  case "$fname" in
    *.zip|*.tar|*.tar.gz|*.tgz|*.gz|*.bz2|*.xz|*.rar|*.7z|\
    *.dmg|*.pkg|*.app|*.exe|*.bin|*.dll|*.so|*.dylib|*.o|*.a|\
    *.jpg|*.jpeg|*.png|*.gif|*.webp|*.mp4|*.mov|*.pdf)
      echo -e "  ${YELLOW}⏭  Skipping (binary extension): ${fname}${NC}"
      return 1 ;;
  esac

  # Skip if binary content detected (NUL bytes in first 1 KB).
  # Uses python3 for portability: macOS BSD grep doesn't support -P / \x00.
  if python3 -c \
      "import sys; sys.exit(0 if b'\x00' in open(sys.argv[1],'rb').read(1024) else 1)" \
      "$f" 2>/dev/null; then
    echo -e "  ${YELLOW}⏭  Skipping (binary content): ${fname}${NC}"
    return 1
  fi

  return 0
}

# Check whether a Vault path already exists.
vault_path_exists() {
  vault kv get "$1" >/dev/null 2>&1
}

# Compute a simple content hash (sha256 first 8 chars).
content_hash() {
  sha256sum "$1" 2>/dev/null | cut -c1-8 \
    || shasum -a 256 "$1" 2>/dev/null | cut -c1-8 \
    || echo "nohash"
}

# Write a file into Vault KV.
vault_write() {
  local file_path="$1"
  local vault_path="$2"
  local fname
  fname="$(basename "$file_path")"

  local content
  content=$(cat "$file_path")
  local size
  size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
  local perms
  perms=$(stat -f%Lp "$file_path" 2>/dev/null || stat -c%a "$file_path" 2>/dev/null)
  local mtime
  mtime=$(stat -f%m "$file_path" 2>/dev/null || stat -c%Y "$file_path" 2>/dev/null)
  local mtime_str
  mtime_str=$(date -r "$mtime" 2>/dev/null || date -d "@$mtime" 2>/dev/null || echo "unknown")
  local hash
  hash=$(content_hash "$file_path")
  local ext="${fname##*.}"
  [ "$ext" = "$fname" ] && ext="none"

  if vault kv put "$vault_path" \
    content="$content" \
    filename="$fname" \
    original_path="$file_path" \
    file_type="$ext" \
    file_size_bytes="$size" \
    file_permissions="$perms" \
    file_modified="$mtime_str" \
    content_hash="$hash" \
    source_host="$(hostname)" \
    synced_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    no_expiration="true" \
    >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# ── collect files ─────────────────────────────────────────────────────────────
mapfile -d '' all_files < <(find "$KEYS_DIR" -type f -print0 | sort -z)

new_count=0
updated_count=0
skipped_exists_count=0
skipped_binary_count=0
error_count=0
list_output=()

for file in "${all_files[@]}"; do
  vault_path=$(file_to_vault_path "$file")
  fname=$(basename "$file")
  exists=false
  vault_path_exists "$vault_path" && exists=true

  # ── --list mode ──────────────────────────────────────────────────────────
  if $LIST_ONLY; then
    if $exists; then
      list_output+=("  ${GREEN}✔ EXISTS${NC}   ${vault_path}   ← ${fname}")
    else
      list_output+=("  ${YELLOW}✘ MISSING${NC}  ${vault_path}   ← ${fname}")
    fi
    continue
  fi

  # ── check if processable ─────────────────────────────────────────────────
  if ! is_processable "$file"; then
    ((skipped_binary_count++))
    continue
  fi

  # ── new-only: skip if already in Vault ───────────────────────────────────
  if [ "$MODE" = "new-only" ] && $exists; then
    echo -e "  ${CYAN}⏭  Already in Vault: ${vault_path}${NC}"
    ((skipped_exists_count++))
    continue
  fi

  # ── dry-run ───────────────────────────────────────────────────────────────
  if [ "$MODE" = "dry-run" ]; then
    if $exists; then
      echo -e "  ${YELLOW}~ UPDATE${NC}  ${vault_path}"
    else
      echo -e "  ${GREEN}+ NEW${NC}     ${vault_path}"
    fi
    $exists && ((skipped_exists_count++)) || ((new_count++))
    continue
  fi

  # ── write to Vault ────────────────────────────────────────────────────────
  if $exists; then
    echo -e "  ${YELLOW}↻  Updating: ${NC}${vault_path}"
  else
    echo -e "  ${GREEN}+  Importing: ${NC}${vault_path}"
  fi

  if vault_write "$file" "$vault_path"; then
    if $exists; then
      ((updated_count++))
      echo -e "     ${GREEN}✅ Updated${NC}"
    else
      ((new_count++))
      echo -e "     ${GREEN}✅ Imported${NC}"
    fi
  else
    ((error_count++))
    echo -e "     ${RED}❌ Failed${NC}"
  fi
done

# ── list output ───────────────────────────────────────────────────────────────
if $LIST_ONLY; then
  echo -e "${BOLD}Local files vs Vault (${#list_output[@]} files):${NC}"
  echo
  missing=0
  for line in "${list_output[@]}"; do
    echo -e "$line"
    [[ "$line" == *"MISSING"* ]] && ((missing++))
  done
  echo
  echo -e "${YELLOW}Missing from Vault: ${missing} / ${#list_output[@]}${NC}"
  echo -e "Run with ${CYAN}--mode=new-only${NC} to import missing files."
  exit 0
fi

# ── summary ───────────────────────────────────────────────────────────────────
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BOLD}Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$MODE" = "dry-run" ] && echo -e "  ${YELLOW}(dry run — nothing was written)${NC}"
echo -e "  ${GREEN}New imported   : ${new_count}${NC}"
echo -e "  ${YELLOW}Updated        : ${updated_count}${NC}"
echo -e "  ${CYAN}Already existed: ${skipped_exists_count}${NC}"
echo -e "  ${YELLOW}Binary/skipped : ${skipped_binary_count}${NC}"
[ "$error_count" -gt 0 ] && echo -e "  ${RED}Errors         : ${error_count}${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo -e "${BLUE}Useful commands:${NC}"
echo "  vault kv list ${VAULT_KV_PREFIX}/"
echo "  vault kv list ${VAULT_KV_PREFIX}/projects/"
echo "  vault kv get  ${VAULT_KV_PREFIX}/<path>"
