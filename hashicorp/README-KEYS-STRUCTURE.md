# ~/.keys — Recommended Structure & Vault Mapping

## The golden rules

1. **One secret per service** (not per file, not per project)
2. **Multiple fields per secret** — a Vault secret is a key→value map, not just a blob
3. **Group by project** for multi-service apps, by type for infrastructure keys

---

## Recommended local folder layout

```
~/.keys/
│
├── # ── Project secrets (multi-value per project) ─────────────────────
├── projects/
│   ├── translation_app/           # ← your existing folder
│   │   ├── supabase               # fields: url, anon_key, service_role_key
│   │   ├── github                 # fields: client_id, client_secret, pat
│   │   └── api_keys               # fields: openai_key, deepl_key, etc.
│   │
│   └── another_project/
│       ├── supabase
│       └── stripe                 # fields: publishable_key, secret_key, webhook_secret
│
├── # ── OAuth app credentials ──────────────────────────────────────────
├── oauth/
│   ├── github_hashicorp_vault     # fields: client_id, client_secret, callback_url
│   ├── github_n8n                 # one file per OAuth app
│   └── github_another_app
│
├── # ── TLS / SSL certificates ─────────────────────────────────────────
├── certs/
│   ├── bryanwills_dev.pem         # fields: cert, private_key (or just content)
│   └── another_domain.pem
│
├── # ── PGP / GPG keys ─────────────────────────────────────────────────
├── pgp/
│   └── bryan_personal.asc
│
├── # ── Configs with embedded secrets ──────────────────────────────────
├── configs/
│   └── some_service.yml
│
└── # ── Flat / legacy keys (your existing 72) ──────────────────────────
    ├── vault_github_token_login   # already there
    ├── ssh_vps                    # single-value files
    └── ...other legacy flat keys
```

Vault paths mirror the folder: `~/.keys/projects/translation_app/supabase`
→ `secret/keys/projects/translation_app/supabase`

---

## Multi-value secrets: how to do it

### Option A — One file = one secret with multiple KEY=VALUE lines
Create `~/.keys/projects/translation_app/supabase` containing:

```
url=https://xyzabc.supabase.co
anon_key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role_key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

The script stores the whole file under the `content` field as-is.
To store each as its own Vault field (better for programmatic access), use the
`vault kv put` command directly:

```bash
vault kv put secret/keys/projects/translation_app/supabase \
  url="https://xyzabc.supabase.co" \
  anon_key="eyJ..." \
  service_role_key="eyJ..."
```

### Option B — Put the whole `.github_oauth_apps` file into Vault as-is
Then over time, split it by creating individual secrets per app:

```bash
# Read the combined file, then create individual secrets
vault kv put secret/keys/oauth/github_hashicorp_vault \
  client_id="Ov23lixYKwYt4vr3V2cU" \
  client_secret="021a558f..." \
  callback_url="https://keys.bryanwills.dev/ui/vault/auth/github/oidc/callback" \
  app_name="HashiCorp Key Vault"
```

---

## File type handling

| Extension | Where to put it locally | Notes |
|-----------|------------------------|-------|
| `.pem` | `~/.keys/certs/` | Text (base64) — stored fine |
| `.asc` | `~/.keys/pgp/` | PGP armored text — stored fine |
| `.yml`/`.yaml` | `~/.keys/configs/` | Watch for variable interpolation |
| `.txt` | wherever logical | Plain text — fine |
| `.json` | `~/.keys/configs/` | Fine as text |
| dotfiles (`.env`, etc.) | `~/.keys/` root or project folder | Strip leading dot in Vault |

---

## Syncing your 32 new keys

```bash
# Step 1: See what's missing (dry run — no writes)
export VAULT_TOKEN=<your_token>
./export-keys-to-vault.sh --list

# Step 2: Preview what would be imported
./export-keys-to-vault.sh --mode=dry-run

# Step 3: Import only the new 32 (skip the existing 72)
./export-keys-to-vault.sh --mode=new-only

# Step 4: Force-update ALL (overwrites existing with latest local version)
./export-keys-to-vault.sh --mode=update
```

---

## Multi-device keys — namespacing by device

Use `--device-prefix=<name>` to keep each machine's keys in its own folder inside Vault.
Prefixing with `_` (underscore) sorts device folders to the top of the Vault UI before
alphabetical key names.

```bash
# On your MacBook
bash export-keys-to-vault.sh --keys-dir=~/.keys --device-prefix=_macbook

# On your VPS (run via SSH or copy the script there)
bash export-keys-to-vault.sh --keys-dir=/home/bryanwi09/.keys --device-prefix=_vps

# On your work laptop (WSL2)
bash export-keys-to-vault.sh --keys-dir=~/.keys --device-prefix=_work
```

Vault paths will be:
```
keys/
  _macbook/        ← sorts to top (underscore before letters)
  _vps/
  _work/
  <flat legacy keys starting with a-z>
```

No need for separate Vault instances — one vault, organized by prefix.

---

## Subfolders within a device prefix

You can nest as deep as you want. The `--device-prefix` and `--keys-dir` flags are
independent — `--keys-dir` controls which local folder is scanned, `--device-prefix`
controls where those files land in Vault.

```bash
# Upload only Jarvis project keys under _macbook/Jarvis/
bash ~/export-keys-to-vault.sh \
  --keys-dir=~/.keys/projects/jarvis \
  --device-prefix=_macbook/Jarvis \
  --mode=new-only

# Upload BigBrainCoding project keys under _macbook/BigBrainCoding/
bash ~/export-keys-to-vault.sh \
  --keys-dir=~/.keys/projects/bigbraincoding \
  --device-prefix=_macbook/BigBrainCoding \
  --mode=new-only
```

The Vault UI renders each `/` as a clickable folder level:
```
keys/
  _macbook/
    Jarvis/
      github_pat
      openai_key
      supabase
    BigBrainCoding/
      stripe_key
      cloudflare_token
      github_pat
  _vps/
    ssh_key
    vault_root_token
  <flat legacy keys>
```

This lets you organize by project, team, or service within each device namespace
without restructuring your local `~/.keys` layout first.

---

## Auto-sync on macOS (launchd WatchPaths)

Two files in this directory handle automatic syncing whenever `~/.keys` changes:
- `vault-key-sync-watch.sh` — the wrapper script run by launchd
- `dev.bryanwills.vault-key-sync.plist` — the launchd agent definition

### Install (one-time on your Mac)

```bash
# 1. Copy both files from your VPS to your Mac
scp bryanwi09@<vps-ip>:/home/bryanwi09/docker/hashicorp/export-keys-to-vault.sh ~/
scp bryanwi09@<vps-ip>:/home/bryanwi09/docker/hashicorp/vault-key-sync-watch.sh ~/
scp bryanwi09@<vps-ip>:/home/bryanwi09/docker/hashicorp/dev.bryanwills.vault-key-sync.plist ~/

# 2. Make scripts executable
chmod +x ~/export-keys-to-vault.sh ~/vault-key-sync-watch.sh

# 3. Install the launchd agent (this reads the plist and registers the watcher)
bash ~/vault-key-sync-watch.sh --install
```

### What happens after install

- macOS monitors `~/.keys` for any file additions or modifications
- When a change is detected, it waits 10 seconds (debounce), then runs `export-keys-to-vault.sh --mode=new-only`
- Only new keys are uploaded — existing ones are never overwritten automatically
- A macOS notification appears when the sync completes or if authentication has expired
- Logs are written to `~/Library/Logs/vault-key-sync.log`

### Check logs

```bash
tail -f ~/Library/Logs/vault-key-sync.log
```

### Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/dev.bryanwills.vault-key-sync.plist
rm ~/Library/LaunchAgents/dev.bryanwills.vault-key-sync.plist
```

### Vault token expiry

The launchd agent runs as your user and reads your cached Vault token (`~/.vault-token`). The token expires every 32 days. When it does, the watcher will send a macOS notification prompting you to re-authenticate:

```bash
vault login -method=github token=<YOUR_PAT>
```

---

## Accessing Vault from other devices (WSL2 / work laptop)

```bash
# Install vault CLI on Ubuntu/WSL2
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

# Add to ~/.bashrc or ~/.zshrc
export VAULT_ADDR="https://keys.bryanwills.dev"

# Login (once per 32 days)
vault login -method=github token=<YOUR_GITHUB_PAT>

# Fetch a secret — no local file needed
vault kv get -field=content -mount=keys macbook/github_pat
```

---

## Using Vault secrets in code

### Shell
```bash
SECRET=$(vault kv get -field=content -mount=keys macbook/github_pat)
```

### Python
```python
import subprocess

def get_secret(key: str, mount: str = "keys") -> str:
    result = subprocess.run(
        ["vault", "kv", "get", "-field=content", f"-mount={mount}", key],
        capture_output=True, text=True, check=True
    )
    return result.stdout.strip()

# Production: use hvac
# pip install hvac
import hvac, os
client = hvac.Client(url=os.environ["VAULT_ADDR"], token=os.environ["VAULT_TOKEN"])
secret = client.secrets.kv.v2.read_secret_version(path="macbook/github_pat", mount_point="keys")
value = secret["data"]["data"]["content"]
```

### TypeScript / Node
```typescript
async function getSecret(key: string, mount = "keys"): Promise<string> {
  const res = await fetch(`${process.env.VAULT_ADDR}/v1/${mount}/data/${key}`, {
    headers: { "X-Vault-Token": process.env.VAULT_TOKEN! },
  });
  const json = await res.json() as { data: { data: Record<string, string> } };
  return json.data.data.content;
}
```

Always inject `VAULT_ADDR` and `VAULT_TOKEN` as environment variables at runtime — never hardcode them.
