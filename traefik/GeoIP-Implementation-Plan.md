# GeoIP Implementation Plan for US-Only Access

## Overview
This plan outlines the steps to implement GeoIP blocking for non-US traffic using MaxMind's GeoLite2 database and Traefik middleware.

## Prerequisites
- Free MaxMind Account
- License key from MaxMind
- Existing Traefik setup

## Directory Structure
```
/home/bryanwi09/docker/traefik/
├── geoip/
│   └── GeoLite2-Country.mmdb  # Will be downloaded
├── traefik.yml                # Existing
└── docker-compose.yml         # Existing
```

## Implementation Steps

### 1. MaxMind Account Setup
- Create free account at MaxMind
- Generate license key
- Create geoip directory:
  ```bash
  mkdir -p /home/bryanwi09/docker/traefik/geoip/
  ```

### 2. Configuration Changes

#### a. Modify traefik.yml
```yaml
# Add to existing traefik.yml
experimental:
  plugins:
    geoip:
      moduleName: github.com/soulbalz/traefik-geoip
      version: v1.0.0
```

#### b. Update docker-compose.yml
```yaml
services:
  traefik:
    # ... existing configuration ...
    volumes:
      # ... existing volumes ...
      - ./geoip:/geoip:ro  # Add this line
    labels:
      # ... existing labels ...
      - "traefik.http.middlewares.us-only.plugin.geoip.db=/geoip/GeoLite2-Country.mmdb"
      - "traefik.http.middlewares.us-only.plugin.geoip.allowedCountries=US"
      - "traefik.http.routers.nginx-secure.middlewares=us-only@docker"
```

### 3. Update Script
Create file: `/home/bryanwi09/docker/traefik/update-geoip.sh`
```bash
#!/bin/bash

# Directory for GeoIP database
GEOIP_DIR="/home/bryanwi09/docker/traefik/geoip"
LICENSE_KEY="your_license_key"  # Replace with actual key

# Create directory if it doesn't exist
mkdir -p "$GEOIP_DIR"

# Download and update database
curl -o "$GEOIP_DIR/GeoLite2-Country.mmdb.gz" \
  "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=$LICENSE_KEY&suffix=tar.gz"

# Extract new database
gunzip -f "$GEOIP_DIR/GeoLite2-Country.mmdb.gz"

# Restart Traefik to ensure it picks up the new database
docker-compose -f /home/bryanwi09/docker/traefik/docker-compose.yml restart traefik
```

### 4. Weekly Updates
Add to system crontab:
```bash
# Run every Monday at 1 AM
0 1 * * 1 /home/bryanwi09/docker/traefik/update-geoip.sh >> /home/bryanwi09/docker/traefik/logs/geoip-update.log 2>&1
```

### 5. Testing
- Use VPN to test from different countries
- Use online tools for testing from different regions
- Monitor Traefik logs for blocked requests
- Verify database updates in logs

## Maintenance
1. Weekly automatic updates via cron
2. Check update logs periodically
3. Monitor MaxMind license key expiration
4. Review Traefik logs for blocked attempts

## Expected Behavior
- Non-US IPs receive 403 Forbidden
- US IPs access normally
- Weekly database updates
- Blocked attempts logged in Traefik logs
