# Docker Dashboards — VPS (Homepage) & Work Azure VM (Homarr)

This folder contains everything for two dashboard projects:

| Environment | Tool | Why | Folder |
| --- | --- | --- | --- |
| **Personal VPS** (`*.bryanwills.dev`) | **Homepage** (`gethomepage`) | Single user, fast static landing page, native Docker status + icons + links. Already deployed here. | `./` (this folder) |
| **Work Azure POC VM** (`example.com`) | **Homarr** | Multi-user, **EntraID/OIDC SSO**, per-user boards, **anonymous public board** (view without login), and a Docker integration that can **start/stop** containers. | `./work-server-homarr/` |

---

## 1. Why these tools (and where Grafana fits)

You asked how Grafana fits. **Grafana is the wrong tool for this.** Grafana is a
time-series **metrics/visualization** platform (graphs from Prometheus, Loki,
etc.). It does not give you a grid of "click the container name to open its
URL + see if it's up" tiles. For an app launcher/landing page you want a
purpose-built dashboard:

| Tool | Per-user accounts | SSO (EntraID) | Container status | Start/stop control | Best for |
| --- | --- | --- | --- | --- | --- |
| **Homepage** | No (single shared YAML) | No | Yes (status + stats) | No (links to Portainer) | Personal VPS, fast public landing |
| **Homarr** | Yes | Yes (OIDC) | Yes | Yes (logged-in admins) | Work, multi-user, SSO |
| Dashy | Local-storage per browser | Limited | Status pings | No | Lightweight personal |
| sun-panel / Dashboard | Minimal | No | Basic | No | Simple launchers |

**Container control caveat:** Homepage cannot start/stop containers — it shows
status and stats only. Real control belongs in **Portainer** (already running at
`portainer.bryanwills.dev`). Homarr *can* control containers for logged-in
admins via its Docker integration.

---

## 2. Personal VPS — Homepage (this folder)

### 2.1 What changed
- `docker-compose.yml` — migrated from the **archived** `benphelps/homepage`
  image to `ghcr.io/gethomepage/homepage:latest`, added the now-**required**
  `HOMEPAGE_ALLOWED_HOSTS`, and made the docker socket read-only.
- `config/docker.yaml` — enabled the `my-docker` socket integration.
- `config/services.yaml` — replaced placeholders with all real services,
  grouped, with icons + live status bindings.
- `config/settings.yaml` — title, dark theme, `target: _blank`, status dots, layout.
- `config/widgets.yaml` — greeting, datetime, system resources, search.

### 2.2 Deploy / refresh
```bash
cd /home/bryanwi09/docker/Homepage
docker compose pull
docker compose up -d --force-recreate
docker logs -f homepage   # Ctrl-C to exit; watch for "Host validation" errors
```
Then open <https://homepage.bryanwills.dev>.

> **Important:** any time you change an `environment:` value (like
> `HOMEPAGE_ALLOWED_HOSTS`) you must `--force-recreate`, not just `restart`.

### 2.3 Add or edit a service
Edit `config/services.yaml`. Each tile looks like:
```yaml
    - Friendly Name:
        href: https://service.bryanwills.dev   # opens in a new tab
        description: short text
        icon: service-slug.png                 # see icons below
        server: my-docker                       # matches docker.yaml label
        container: actual_container_name        # for live status/stats
```
Changes are picked up automatically — just refresh the browser.

### 2.4 Icons
Icons auto-resolve from the
[dashboard-icons](https://github.com/homarr-labs/dashboard-icons) set. Use the
slug + `.png` (e.g. `n8n.png`, `pi-hole.png`, `vaultwarden.png`). You can also
use `mdi-<name>` Material icons or `si-<name>` simple-icons, or a full URL.

### 2.5 Container control
Click any status dot to expand live CPU/MEM/network stats. For start/stop/
restart, use the **Portainer** tile (control intentionally stays in Portainer).

---

## 3. Work Azure VM — Homarr (`./work-server-homarr/`)

This server hosts 50+ POC containers reachable at `https://example.com/netbox`,
`/nautobot`, etc. The root `https://example.com` (currently a 404) becomes the
Homarr dashboard. Users can **view containers without logging in**, click
through to an app, and authenticate there. Admins can log in (EntraID SSO) to
customize boards and control containers.

### 3.1 Copy the files to the work VM
Put `work-server-homarr/` somewhere like `/opt/homarr/` (or your docker dir) on
the Azure VM, then:
```bash
cd /opt/homarr            # wherever you placed the folder
cp .env.example .env
openssl rand -hex 32      # paste output into SECRET_ENCRYPTION_KEY in .env
```

### 3.2 Find the correct Traefik network (placeholder extraction)
The compose file uses `${PROXY_NETWORK}` (default `proxy`). Confirm the real
name on the work VM:
```bash
# Name(s) of the network(s) Traefik is attached to:
docker inspect traefik -f '{{json .NetworkSettings.Networks}}' | tr ',' '\n' | grep -oE '"[^"]+":' | head

# Or list everything and eyeball it:
docker network ls
```
Set `PROXY_NETWORK=` in `.env` to that value.

### 3.3 Fill in `.env`
Set `HOMARR_FQDN`, `BASE_URL`, `NEXTAUTH_URL` to your real work domain
(replace `example.com`). Leave EntraID values until section 3.5 if you want to
start with a local admin first.

### 3.4 Start Homarr
```bash
docker compose up -d
docker logs -f homarr
```
Open `https://<your-domain>`. On first load you create the **local admin**
(works even before SSO). 

> **Routing note:** the Homarr router is set to `priority=1` so the longer path
> routers (`/netbox`, `/nautobot`, …) always win. Homarr only answers the bare
> root. If your existing apps are matched by `PathPrefix`, this just works; if
> any app also claims the bare host, give Homarr a dedicated subdomain instead
> (e.g. `dash.example.com`).

### 3.5 EntraID (Azure AD) SSO — step by step
1. **Entra admin center → App registrations → New registration.**
   - Name: `Homarr`.
   - Redirect URI (type **Web**): `https://<your-domain>/api/auth/callback/oidc`
2. **Certificates & secrets → New client secret.** Copy the **Value** (not the ID).
3. **Overview** → copy **Application (client) ID** and **Directory (tenant) ID**.
4. In `.env` set:
   - `AUTH_OIDC_CLIENT_ID=<application client id>`
   - `AUTH_OIDC_CLIENT_SECRET=<secret value>`
   - `AUTH_OIDC_ISSUER=https://login.microsoftonline.com/<tenant id>/v2.0`
   - `AUTH_PROVIDERS=credentials,oidc` (keep credentials as fallback)
5. (Optional admin mapping) **Token configuration → Add groups claim**, then set
   `AUTH_OIDC_ADMIN_GROUP=<group object id>` in `.env`. Create a Homarr group
   with the **same** name/id so it maps automatically.
6. `docker compose up -d --force-recreate` and test "Sign in with EntraID".

### 3.6 Anonymous (no-login) board
In Homarr: open the board → **Settings / customize → enable "Allow guests"
(anonymous access)**. This is what lets staff view the container grid without
logging in, then click into NetBox/Nautobot and authenticate at the app.

### 3.7 Bulk-add the 50+ containers
Two options:
- **Docker integration (recommended):** add the Docker integration in Homarr
  (it uses the mounted socket) to auto-discover containers and statuses, then
  drag them onto the board and set each `href` to `https://<domain>/<name>`.
- **Generate a starting list** with the helper script (section 4) and paste the
  hrefs in.

---

## 4. `scripts/extract-services.sh` — inventory any server

Run on **either** server to dump networks, a container table, and a
ready-to-paste Homepage `services.yaml` snippet:
```bash
/home/bryanwi09/docker/Homepage/scripts/extract-services.sh            # full report
/home/bryanwi09/docker/Homepage/scripts/extract-services.sh --yaml-only > new-services.yaml
```
It is read-only and never modifies containers. Review hostnames before pasting,
since it guesses `href` from the first Traefik `Host()` label it finds.

---

## 5. Troubleshooting

- **Blank page / "Host validation failed"** → `HOMEPAGE_ALLOWED_HOSTS` missing
  or wrong. Set it to the exact FQDN and `docker compose up -d --force-recreate`.
- **All status dots grey/"unknown"** → docker socket not readable. Confirm
  `/var/run/docker.sock:/var/run/docker.sock:ro` is mounted and the container
  can read it. For a non-root hardening option, see section 6.
- **`docs.bryanwills.dev` conflict** → both `docmost` and `affine_server` carry
  a `Host(\`docs.bryanwills.dev\`)` Traefik label. Only one can win. Decide which
  app owns that hostname and remove/relabel the other (e.g. move Affine to
  `affine.bryanwills.dev`). The dashboard currently points `docs.bryanwills.dev`
  at Docmost.
- **Homarr SSO works but groups/admin don't** → Azure sends group **object IDs**
  in the `groups` claim, and you must add a groups claim in **Token
  configuration**. Map the object id via `AUTH_OIDC_ADMIN_GROUP`.

---

## 6. (Optional) Hardening: docker-socket-proxy

Mounting the raw socket (even read-only) grants broad visibility. For a
locked-down setup, run [`tecnativa/docker-socket-proxy`](https://github.com/Tecnativa/docker-socket-proxy)
with `CONTAINERS=1`, `POST=0` and point the dashboard at `tcp://dockerproxy:2375`
instead of the socket. Documented at <https://gethomepage.dev/configs/docker/>.
