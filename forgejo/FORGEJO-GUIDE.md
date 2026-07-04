# Forgejo Self-Hosted Git Guide

> **Instance**: https://git.bryanwills.dev  
> **SSH**: `git@git.bryanwills.dev` (port 2222)  
> **Admin**: bryanwills

---

## Table of Contents

1. [Adding Forgejo as a dual push remote (any existing repo)](#1-adding-forgejo-as-a-dual-push-remote)
2. [Setting up pinned GitHub repos on Forgejo](#2-setting-up-pinned-repos)
3. [Dotfiles setup](#3-dotfiles-setup)
4. [Template — new repos going forward](#4-template-for-new-repos)
5. [Cloud storage skeleton (future)](#5-cloud-storage-skeleton)

---

## 1. Adding Forgejo as a Dual Push Remote

This is the pattern used for `docker` and `MealForge`. One `git push` sends to both GitHub and Forgejo.

### Prerequisites

On your Mac, ensure your SSH config includes:

```
# ~/.ssh/config
Host git.bryanwills.dev
  HostName git.bryanwills.dev
  User git
  Port 2222
  IdentityFile ~/.ssh/gitbryanwills_nopass
  ProxyCommand ssh -W %h:%p bryanwills@bryanwills.dev
  ServerAliveInterval 60
  ServerAliveCountMax 5
```

### Steps for any existing GitHub repo

```bash
# 1. Navigate to the repo
cd ~/path/to/your-repo

# 2. Verify current remote (fetch stays GitHub-only)
git remote -v

# 3. Ensure GitHub push URL is set first
git remote set-url --add --push origin https://github.com/bryanwills/REPO_NAME.git

# 4. Add Forgejo as a second push destination
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/REPO_NAME.git

# 5. Confirm both push URLs are listed
git remote -v
# origin  https://github.com/bryanwills/REPO_NAME.git (fetch)
# origin  https://github.com/bryanwills/REPO_NAME.git (push)
# origin  git@git.bryanwills.dev:bryanwills/REPO_NAME.git (push)

# 6. Push — goes to GitHub + Forgejo simultaneously
git push origin main
```

### Create the repo on Forgejo first (API)

```bash
export FORGEJO_TOKEN="<your-token>"   # generate at https://git.bryanwills.dev/user/settings/applications

curl -s -X POST "https://git.bryanwills.dev/api/v1/user/repos" \
  -H "Authorization: token ${FORGEJO_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "REPO_NAME",
    "description": "Short description",
    "private": false,
    "auto_init": false,
    "default_branch": "main"
  }'
```

---

## 2. Setting Up Pinned Repos

The following repos have been created on Forgejo. Run these commands from your **Mac** to wire each one up.

| GitHub Repo | Forgejo URL | Notes |
|---|---|---|
| `bryanwills/docker` | `git.bryanwills.dev/bryanwills/docker` | VPS manages this — already configured via HTTPS token |
| `bryanwills/mealforge` | `git.bryanwills.dev/bryanwills/mealforge` | Already configured in previous session |
| `bryanwills/dotfiles` | `git.bryanwills.dev/bryanwills/dotfiles` | See Section 3 |
| `bryanwills/bigbraincoding` | `git.bryanwills.dev/bryanwills/bigbraincoding` | |
| `bryanwills/developer-portfolio` | `git.bryanwills.dev/bryanwills/developer-portfolio` | |
| `bryanwills/FrontEndWebDevDesigns` | `git.bryanwills.dev/bryanwills/FrontEndWebDevDesigns` | |
| `bryanwills/certifications` | `git.bryanwills.dev/bryanwills/certifications` | |

### Mac setup for each repo

```bash
# bigbraincoding
cd ~/path/to/bigbraincoding
git remote set-url --add --push origin https://github.com/bryanwills/bigbraincoding.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/bigbraincoding.git
git push origin main

# developer-portfolio
cd ~/path/to/developer-portfolio
git remote set-url --add --push origin https://github.com/bryanwills/developer-portfolio.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/developer-portfolio.git
git push origin main

# FrontEndWebDevDesigns
cd ~/path/to/FrontEndWebDevDesigns
git remote set-url --add --push origin https://github.com/bryanwills/FrontEndWebDevDesigns.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/FrontEndWebDevDesigns.git
git push origin main

# certifications
cd ~/path/to/certifications
git remote set-url --add --push origin https://github.com/bryanwills/certifications.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/certifications.git
git push origin main
```

---

## 3. Dotfiles Setup

Dotfiles typically live at `~/dotfiles` or `~/.config` with a manager like `chezmoi` or `GNU stow`.

```bash
# If dotfiles is a plain git repo at ~/dotfiles
cd ~/dotfiles   # adjust if different path

# Wire up dual remotes
git remote set-url --add --push origin https://github.com/bryanwills/dotfiles.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/dotfiles.git

# Push all branches to both
git push origin --all
git push origin --tags

# Verify
git remote -v
```

If you use **chezmoi**:

```bash
cd ~/.local/share/chezmoi   # default chezmoi source dir
git remote set-url --add --push origin https://github.com/bryanwills/dotfiles.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/dotfiles.git
git push origin main
```

---

## 4. Template — New Repos Going Forward

Use this checklist every time you create a new repo you want on both GitHub and Forgejo.

### Step 1: Create on GitHub (as usual)

```bash
gh repo create bryanwills/NEW_REPO --public --source=. --remote=origin --push
```

### Step 2: Create on Forgejo

```bash
export FORGEJO_TOKEN="<your-token>"

curl -s -X POST "https://git.bryanwills.dev/api/v1/user/repos" \
  -H "Authorization: token ${FORGEJO_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"NEW_REPO\",\"description\":\"Repo description\",\"private\":false,\"auto_init\":false,\"default_branch\":\"main\"}"
```

### Step 3: Add Forgejo as push destination

```bash
cd ~/path/to/NEW_REPO
git remote set-url --add --push origin https://github.com/bryanwills/NEW_REPO.git
git remote set-url --add --push origin git@git.bryanwills.dev:bryanwills/NEW_REPO.git
```

### Step 4: From now on, just push normally

```bash
git push   # goes to GitHub + Forgejo simultaneously
```

### Shell function (add to `~/.zshrc`)

```zsh
# Add Forgejo as dual-push remote for current repo
forgejo-mirror() {
  local repo_name="${1:-$(basename $(git rev-parse --show-toplevel))}"
  local token="${FORGEJO_TOKEN:?Set FORGEJO_TOKEN env var}"

  # Create on Forgejo
  curl -s -X POST "https://git.bryanwills.dev/api/v1/user/repos" \
    -H "Authorization: token ${token}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${repo_name}\",\"private\":false,\"auto_init\":false}" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print('Forgejo:', d.get('html_url', d.get('message','')))"

  # Wire push URL
  git remote set-url --add --push origin \
    "git@git.bryanwills.dev:bryanwills/${repo_name}.git"

  echo "Done. Next git push goes to GitHub + Forgejo."
}
```

---

## 5. Cloud Storage Skeleton

> Not deploying now — here's the skeleton when you're ready.

### Option A: rclone + Google Drive mount (recommended)

rclone supports mounting Google Drive, iCloud (via WebDAV), S3, Backblaze B2, and more as a FUSE filesystem.

```bash
# Install rclone on VPS
curl https://rclone.org/install.sh | sudo bash

# Configure a remote interactively
rclone config
# → choose "n" for new remote
# → name: "gdrive"
# → type: "drive" (Google Drive)
# → follow OAuth flow from a browser on your Mac

# Test mount
rclone lsd gdrive:

# Mount persistently (add to systemd service below)
rclone mount gdrive:vps-storage /mnt/cloud-storage \
  --vfs-cache-mode writes \
  --allow-other \
  --daemon
```

**Systemd unit for persistent mount** (`/etc/systemd/system/rclone-gdrive.service`):

```ini
[Unit]
Description=rclone Google Drive mount
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount gdrive:vps-storage /mnt/cloud-storage \
  --vfs-cache-mode writes \
  --allow-other \
  --log-level INFO \
  --log-file /var/log/rclone.log
ExecStop=/bin/fusermount -u /mnt/cloud-storage
Restart=on-failure
User=bryanwi09

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now rclone-gdrive
```

### Option B: rsync to NAS / future homelab

```bash
# One-shot sync from VPS to NAS over SSH
rsync -avz --delete \
  /home/bryanwi09/docker/forgejo/data/git/ \
  user@nas-ip:/volume1/git-backup/forgejo/

# Or via cron (daily at 2am)
# 0 2 * * * rsync -az /home/bryanwi09/docker/forgejo/data/git/ user@nas-ip:/volume1/git-backup/forgejo/
```

### Option C: iCloud via WebDAV

```bash
# iCloud WebDAV: https://idmsa.apple.com/IDMSWebAuth/signin.html
# rclone config → type: webdav → url: https://idav.icloud.com → vendor: other
# Note: iCloud WebDAV requires an app-specific password from appleid.apple.com
rclone config
# → name: icloud
# → type: webdav
# → url: https://idav.icloud.com
# → user: your-apple-id@email.com
# → password: <app-specific-password>
```

### Disk space note

Your Forgejo instance's git data lives at:

```
/home/bryanwi09/docker/forgejo/data/git/repositories/
```

Check usage:

```bash
du -sh /home/bryanwi09/docker/forgejo/data/
df -h /home/bryanwi09/docker/
```

For the Dell R510 NAS (15TB) — when ready, mount it as an NFS share and point Forgejo's repository path there via `app.ini`:

```ini
[repository]
ROOT = /mnt/nas/git/repositories
```
