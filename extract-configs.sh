#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_status() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# Function to extract container config
extract_container_config() {
    local container_name=$1
    local output_dir=$2

    if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        print_status "Extracting config for ${container_name}..."

        # Create output directory
        mkdir -p "${output_dir}"

        # Extract full container config
        docker inspect "${container_name}" > "${output_dir}/${container_name}-full-config.json"

        # Extract environment variables
        docker exec "${container_name}" printenv > "${output_dir}/${container_name}.env" 2>/dev/null || true

        # Extract labels
        docker inspect --format='{{range $k, $v := .Config.Labels}}{{$k}}={{$v}}{{"\n"}}{{end}}' "${container_name}" > "${output_dir}/${container_name}-labels.txt"

        # Extract volume mounts
        docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}}{{"\n"}}{{end}}' "${container_name}" > "${output_dir}/${container_name}-volumes.txt"

        # Extract port mappings
        docker port "${container_name}" > "${output_dir}/${container_name}-ports.txt" 2>/dev/null || true

        # Extract network info
        docker inspect --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}:{{$v.IPAddress}}{{"\n"}}{{end}}' "${container_name}" > "${output_dir}/${container_name}-networks.txt"

        print_success "Extracted config for ${container_name}"
    else
        print_warning "Container ${container_name} not found or not running"
    fi
}

# Main extraction process
print_status "Starting configuration extraction..."

# Extract from main services
extract_container_config "keycloak" "extracted-configs/keycloak"
extract_container_config "keycloak-db" "extracted-configs/keycloak"
extract_container_config "pihole" "extracted-configs/dns-adblock"
extract_container_config "traefik" "extracted-configs/traefik"
extract_container_config "authentik_server" "extracted-configs/authentik"
extract_container_config "authentik_postgres" "extracted-configs/authentik"
extract_container_config "authentik_redis" "extracted-configs/authentik"

# Extract from other services if they exist
extract_container_config "n8n" "extracted-configs/n8n"
extract_container_config "n8n-db" "extracted-configs/n8n"
extract_container_config "code-server" "extracted-configs/code-server"
extract_container_config "linkwarden" "extracted-configs/linkwarden"
extract_container_config "linkwarden-db" "extracted-configs/linkwarden"
extract_container_config "uptime-kuma" "extracted-configs/uptime-kuma"
extract_container_config "excalidraw" "extracted-configs/draw"
extract_container_config "vaultwarden" "extracted-configs/vaultwarden"

print_success "Configuration extraction complete!"
print_status "Check the 'extracted-configs' directory for all extracted configurations"
print_status "You can now review and copy the relevant parts to your docker-compose.yml files"