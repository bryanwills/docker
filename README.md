# Bryan Wills Docker Infrastructure

This repository contains all Docker Compose configurations for the bryanwills.dev infrastructure.

## 🚀 Services Overview

### Core Infrastructure
- **Traefik** (`traefik/`) - Reverse proxy with SSL termination and automatic certificate management
- **Keycloak** (`keycloak/`) - Identity and access management
- **Authentik** (`authentik/`) - Alternative identity provider (backup)

### DNS & Networking
- **Pi-hole** (`dns-adblock/`) - Ad-blocking DNS server with local zone management
- **BIND9** (`dns-authoritative/`) - Authoritative DNS server (optional)

### Development & Productivity
- **Code Server** (`code-server/`) - VS Code in the browser
- **n8n** (`n8n/`) - Workflow automation platform
- **Excalidraw** (`draw/`) - Collaborative drawing tool
- **Linkwarden** (`linkwarden/`) - Bookmark and link management

### Monitoring & Observability
- **Uptime Kuma** (`uptime-kuma/`) - Uptime monitoring
- **Grafana Monitoring** (`Grafana-Monitoring/`) - Metrics visualization
- **Syslog Server** (`syslog-server/`) - Centralized logging

### Utilities
- **Vaultwarden** (`vaultwarden/`) - Password manager
- **Homepage** (`Homepage/`) - Dashboard for all services
- **IT Tools** (`IT-Tools/`) - IT utilities collection
- **Docmost** (`docmost/`) - Documentation platform
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

## 🛠️ Maintenance

### DNS Management
```bash
# Whitelist a domain in Pi-hole
cd dns-adblock
./whitelist.sh example.com
```

### Service Updates
```bash
# Update a specific service
cd <service-directory>
docker compose pull
docker compose up -d
```

### Logs
```bash
# View service logs
docker compose logs -f <service-name>
```

## 📁 Directory Structure

```
docker/
├── traefik/           # Reverse proxy
├── keycloak/          # Authentication
├── authentik/         # Alternative auth
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
├── docmost/           # Documentation
├── nginx/             # Web server
├── syslog-server/     # Centralized logging
└── Grafana-Monitoring/ # Metrics visualization
```

## 🔄 Environment Variables

Each service directory contains a `.env` file with service-specific variables. Key variables include:

- `POSTGRES_PASSWORD` - Database passwords
- `WEBPASSWORD` - Pi-hole admin password
- `KEYCLOAK_ADMIN_PASSWORD` - Keycloak admin password
- `CODE_SERVER_PASSWORD` - Code Server password
- `N8N_PASSWORD` - n8n admin password

## 📝 Notes

- All services use the external `proxy` network for Traefik integration
- DNS services expose port 53 for external access
- Sensitive data is stored in `.env` files (not committed)
- Docker volumes persist data across container restarts
