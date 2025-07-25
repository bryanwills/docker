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

# Function to convert container config to docker-compose.yml
convert_to_compose() {
    local container_name=$1
    local service_dir=$2

    if [ -f "extracted-configs/${service_dir}/${container_name}-full-config.json" ]; then
        print_status "Converting ${container_name} to docker-compose.yml..."

        # Create the service directory if it doesn't exist
        mkdir -p "${service_dir}"

        # Extract image name
        local image=$(jq -r '.[0].Config.Image' "extracted-configs/${service_dir}/${container_name}-full-config.json")

        # Extract environment variables
        local env_vars=""
        if [ -f "extracted-configs/${service_dir}/${container_name}.env" ]; then
            env_vars=$(cat "extracted-configs/${service_dir}/${container_name}.env" | grep -v '^$' | sed 's/^/      - /')
        fi

        # Extract labels
        local labels=""
        if [ -f "extracted-configs/${service_dir}/${container_name}-labels.txt" ]; then
            labels=$(cat "extracted-configs/${service_dir}/${container_name}-labels.txt" | grep -v '^$' | sed 's/^/      - "/;s/$/"/')
        fi

        # Extract volumes
        local volumes=""
        if [ -f "extracted-configs/${service_dir}/${container_name}-volumes.txt" ]; then
            volumes=$(cat "extracted-configs/${service_dir}/${container_name}-volumes.txt" | grep -v '^$' | sed 's/^/      - /')
        fi

        # Extract ports
        local ports=""
        if [ -f "extracted-configs/${service_dir}/${container_name}-ports.txt" ]; then
            ports=$(cat "extracted-configs/${service_dir}/${container_name}-ports.txt" | grep -v '^$' | sed 's/^/      - "/;s/$/"/')
        fi

        # Create docker-compose.yml for this service
        cat > "${service_dir}/docker-compose.yml" << EOF
version: "3.9"
services:
  ${container_name}:
    image: ${image}
    container_name: ${container_name}
    restart: unless-stopped
EOF

        # Add environment variables if they exist
        if [ ! -z "$env_vars" ]; then
            echo "    environment:" >> "${service_dir}/docker-compose.yml"
            echo "$env_vars" >> "${service_dir}/docker-compose.yml"
        fi

        # Add volumes if they exist
        if [ ! -z "$volumes" ]; then
            echo "    volumes:" >> "${service_dir}/docker-compose.yml"
            echo "$volumes" >> "${service_dir}/docker-compose.yml"
        fi

        # Add ports if they exist
        if [ ! -z "$ports" ]; then
            echo "    ports:" >> "${service_dir}/docker-compose.yml"
            echo "$ports" >> "${service_dir}/docker-compose.yml"
        fi

        # Add labels if they exist
        if [ ! -z "$labels" ]; then
            echo "    labels:" >> "${service_dir}/docker-compose.yml"
            echo "$labels" >> "${service_dir}/docker-compose.yml"
        fi

        # Add networks
        echo "    networks:" >> "${service_dir}/docker-compose.yml"
        echo "      - proxy" >> "${service_dir}/docker-compose.yml"

        # Add networks section
        echo "" >> "${service_dir}/docker-compose.yml"
        echo "networks:" >> "${service_dir}/docker-compose.yml"
        echo "  proxy:" >> "${service_dir}/docker-compose.yml"
        echo "    external: true" >> "${service_dir}/docker-compose.yml"

        print_success "Created docker-compose.yml for ${container_name}"
    else
        print_warning "No configuration found for ${container_name}"
    fi
}

# Main conversion process
print_status "Starting conversion to docker-compose.yml..."

# Convert main services
convert_to_compose "keycloak" "keycloak"
convert_to_compose "keycloak-db" "keycloak"
convert_to_compose "pihole" "dns-adblock"
convert_to_compose "traefik" "traefik"
convert_to_compose "authentik_server" "authentik"
convert_to_compose "authentik_postgres" "authentik"
convert_to_compose "authentik_redis" "authentik"

# Convert other services
convert_to_compose "n8n" "n8n"
convert_to_compose "n8n-db" "n8n"
convert_to_compose "code-server" "code-server"
convert_to_compose "linkwarden" "linkwarden"
convert_to_compose "linkwarden-db" "linkwarden"
convert_to_compose "uptime-kuma" "uptime-kuma"
convert_to_compose "excalidraw" "draw"
convert_to_compose "vaultwarden" "vaultwarden"

print_success "Conversion complete!"
print_status "Review the generated docker-compose.yml files and merge them as needed"
