# OpenTofu — Infrastructure as Code

OpenTofu is the open-source successor to Terraform (1:1 compatible CLI).  
It is managed through **Semaphore UI** at `https://ansible.bryanwills.dev`, the same
web UI you use for Ansible.

## Quick orientation

| Tool | What it does | Semaphore project type |
|------|-------------|------------------------|
| **Ansible** | Configures existing servers / containers | `Ansible` |
| **OpenTofu** | Creates & destroys infrastructure resources | `OpenTofu` |

Both tools live in the same `semaphoreui/semaphore:latest` container — no
separate binary or container needed.

---

## Folder layout

```
opentofu/
├── examples/
│   ├── 01-hello-local/      # No credentials needed — start here
│   └── 02-docker-provider/  # Manage Docker containers with tofu
└── state/                   # Local state files (gitignored)
```

---

## First run: getting started in Semaphore

### 1. Log in

Browse to `https://ansible.bryanwills.dev` and log in with the admin account
you set in `ansible/.env`.

### 2. Create an OpenTofu project

1. Click **New Project** (top-right).
2. Fill in:
   - **Name**: `OpenTofu Examples`
   - **App**: `OpenTofu`   ← this is the key selector
3. Save.

### 3. Add the repository (local path)

Inside your new project, go to **Repositories → Add Repository**:

| Field | Value |
|-------|-------|
| Name | `opentofu-local` |
| URL / Path | `/opentofu` |
| Branch | *(leave blank — it's a local path)* |

> Semaphore also supports GitHub/GitLab repos. For a Git-backed workflow, push
> this `opentofu/` folder to a repo and point Semaphore at the clone URL.

### 4. Add an Inventory (required by Semaphore, even for OpenTofu)

Go to **Inventory → Add Inventory**:
- **Name**: `localhost`
- **Type**: `Static`
- Content: `localhost ansible_connection=local`

### 5. Create a Task Template for Example 01

Go to **Task Templates → Add**:

| Field | Value |
|-------|-------|
| Name | `Hello Local` |
| App | `OpenTofu` |
| Repository | `opentofu-local` |
| Playbook (directory) | `examples/01-hello-local` |
| Inventory | `localhost` |
| Extra CLI flags | *(leave blank)* |

Click **Run** — Semaphore will run `tofu init && tofu apply -auto-approve`.

### 6. OpenTofu workflow in Semaphore

Each task template maps to one `tofu` command:

| Button | What runs |
|--------|-----------|
| **Run** | `tofu init && tofu apply` |
| **Run with override** → destroy | `tofu init && tofu destroy` |

---

## Example 02 — Docker Provider

This example creates a real Docker container using OpenTofu. Before running it,
the Semaphore container needs Docker socket access.

Add to `ansible/docker-compose.yml` under `volumes:`:
```yaml
- /var/run/docker.sock:/var/run/docker.sock
```

Then recreate the container:
```bash
cd ~/docker/ansible && docker compose up -d --force-recreate
```

Create a Task Template for it (same steps as above, but directory =
`examples/02-docker-provider`).

---

## State management

Local state (default) is stored in `state/` which is mounted into Semaphore at
`/tofu-state/` and is gitignored. This is fine for a single-person homelab.

For a team environment, migrate to a remote backend:
- **S3-compatible** (MinIO, AWS S3, Cloudflare R2)
- **Semaphore Pro** has a built-in HTTP state backend

---

## Useful commands (inside Semaphore container or locally)

```bash
# Enter the running Semaphore container
docker exec -it semaphore sh

# Run OpenTofu manually
tofu -chdir=/opentofu/examples/01-hello-local init
tofu -chdir=/opentofu/examples/01-hello-local plan
tofu -chdir=/opentofu/examples/01-hello-local apply -auto-approve
tofu -chdir=/opentofu/examples/01-hello-local destroy -auto-approve

# Check versions
tofu version
ansible --version
```
