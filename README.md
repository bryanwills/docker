# Bryan Wills Docker Infrastructure

This repository contains all Docker Compose configurations for the bryanwills.dev infrastructure.

## 🚀 Services Overview

### Core Infrastructure
- **Traefik** (`traefik/`) - Reverse proxy with SSL termination and automatic certificate management
- **Keycloak** (`keycloak/`) - Identity and access management
- **Authentik** (`authentik/`) - Alternative identity provider (backup)
- **HashiCorp Vault** (`hashicorp/`) - Secrets management and encryption

### DNS & Networking
- **Pi-hole** (`dns-adblock/`) - Ad-blocking DNS server with local zone management
- **BIND9** (`dns-authoritative/`) - Authoritative DNS server (optional)

### Development & Productivity
- **Code Server** (`code-server/`) - VS Code in the browser
- **n8n** (`n8n/`) - Workflow automation platform
- **Excalidraw** (`draw/`) - Collaborative drawing tool
- **Linkwarden** (`linkwarden/`) - Bookmark and link management
- **Tooljet** (`tooljet/`) - Low-code platform for building internal tools
- **Gist** (`gist/`) - Self-hosted code snippet and gist service

### Monitoring & Observability
- **Uptime Kuma** (`uptime-kuma/`) - Uptime monitoring
- **Grafana Monitoring** (`Grafana-Monitoring/`) - Metrics visualization
- **Syslog Server** (`syslog-server/`) - Centralized logging

### Utilities
- **Vaultwarden** (`vaultwarden/`) - Password manager
- **Homepage** (`Homepage/`) - Dashboard for all services
- **IT Tools** (`IT-Tools/`) - IT utilities collection
- **Affine** (`affine/`) - Self-hosted knowledge management with PostgreSQL storage
- **Nginx** (`nginx/`) - Web server

## 🔧 Quick Start

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd docker
   ```

2. **Create the proxy network**
   ```bash
   docker network create proxy
   ```

3. **Set up environment variables**
   - Copy `.env.example` files to `.env` in each service directory
   - Update passwords and secrets

4. **Start Traefik first**
   ```bash
   cd traefik
   docker compose up -d
   cd ..
   ```

5. **Start other services**
   ```bash
   # Start DNS services
   cd dns-adblock
   docker compose up -d
   cd ..

   # Start authentication
   cd keycloak
   docker compose up -d
   cd ..

   # Start secrets management
   cd hashicorp
   docker compose up -d
   cd ..

   # Start other services as needed
   ```

## 🌐 Domain Configuration

All services are configured with the following domain pattern:
- `auth.bryanwills.dev` - Keycloak
- `dns.bryanwills.dev` - Pi-hole
- `draw.bryanwills.dev` - Excalidraw
- `code.bryanwills.dev` - Code Server
- `n8n.bryanwills.dev` - n8n
- `link.bryanwills.dev` - Linkwarden
- `uptime.bryanwills.dev` - Uptime Kuma
- `docs.bryanwills.dev` - Affine Knowledge Management
- `tooljet.bryanwills.dev` - Tooljet Low-code Platform
- `gist.bryanwills.dev` - Gist Code Snippets
- `keys.bryanwills.dev` - HashiCorp Vault Secrets Management
- `traefik.bryanwills.dev` - Traefik Dashboard

## 🔐 Security

- All services use HTTPS with Let's Encrypt certificates
- Traefik handles SSL termination
- Services are isolated in Docker networks
- Environment files contain sensitive data (not committed to git)

## 📊 Monitoring

- **Traefik Dashboard**: `https://traefik.bryanwills.dev`
- **Pi-hole Admin**: `https://dns.bryanwills.dev/admin`
- **Uptime Kuma**: `https://uptime.bryanwills.dev`
- **Affine Admin**: `https://docs.bryanwills.dev/admin`
- **Vault Dashboard**: `https://keys.bryanwills.dev`

## 📁 Directory Structure

```
docker/
├── traefik/           # Reverse proxy
├── keycloak/          # Authentication
├── authentik/         # Alternative auth
├── hashicorp/         # HashiCorp Vault secrets management
├── dns-adblock/       # Pi-hole DNS
├── dns-authoritative/ # BIND9 DNS
├── draw/              # Excalidraw
├── code-server/       # VS Code in browser
├── n8n/               # Workflow automation
├── linkwarden/        # Bookmark manager
├── uptime-kuma/       # Uptime monitoring
├── vaultwarden/       # Password manager
├── Homepage/          # Dashboard
├── IT-Tools/          # IT utilities
├── affine/            # Knowledge management
├── tooljet/           # Low-code platform
├── gist/              # Code snippets and gists
├── nginx/             # Web server
├── syslog-server/     # Centralized logging
└── Grafana-Monitoring/ # Metrics visualization
```

## 🛠️ Maintenance

### Database Backups
```bash
# Affine database is automatically backed up daily at midnight
# Backups are stored in: ~/.affine/self-host/backups/
# Manual backup: cd affine && ./backup_affine.sh
# Restore backup: gunzip -c backups/affine_backup_YYYYMMDD_HHMMSS.sql.gz | docker exec -i affine_postgres psql -U affine -d affine
```

### DNS Management
```bash
# Whitelist a domain in Pi-hole
cd dns-adblock
./whitelist.sh example.com
```

### Service Updates
```
```

## 🔄 Environment Variables

Each service directory contains a `.env` file with service-specific variables. Key variables include:

- `POSTGRES_PASSWORD` - Database passwords
- `WEBPASSWORD` - Pi-hole admin password
- `KEYCLOAK_ADMIN_PASSWORD` - Keycloak admin password
- `CODE_SERVER_PASSWORD` - Code Server password
- `N8N_PASSWORD` - n8n admin password
- `AFFINE_SERVER_STORAGE_TYPE` - Affine storage type (postgres)
- `AFFINE_SERVER_STORAGE_POSTGRES_URL` - Affine database connection
- `GITHUB_CLIENT_ID` & `GITHUB_SECRET_ID` - GitHub OAuth for Affine
- `PG_DB` & `TOOLJET_DB` - Tooljet database names (app database and internal database)
- `PG_HOST` & `PG_USER` & `PG_PASS` - Tooljet database connection credentials
- `GITHUB_CLIENT_ID` & `GITHUB_CLIENT_SECRET` - GitHub OAuth for Gist authentication
- `SECRET_KEY` & `SESSION_SECRET` - Gist security keys
- `GITHUB_OAUTH_CLIENT_ID` & `GITHUB_OAUTH_CLIENT_SECRET` - GitHub OAuth for Vault authentication
- `GITHUB_ORGANIZATION` & `GITHUB_USERNAME` - GitHub organization and username for Vault auth
```

## 📝 Notes

- All services use the external `proxy` network for Traefik integration
- DNS services expose port 53 for external access
- Sensitive data is stored in `.env` files (not committed)
- Docker volumes persist data across container restarts
- Vault runs in production mode with GitHub OAuth authentication