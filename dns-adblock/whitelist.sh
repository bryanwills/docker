#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if domain is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <domain>"
    echo "Example: $0 example.com"
    exit 1
fi

DOMAIN=$1

echo "Whitelisting domain: $DOMAIN"

# Execute the whitelist command in the Pi-hole container
docker exec pihole pihole allow $DOMAIN

if [ $? -eq 0 ]; then
    print_success "Successfully whitelisted: $DOMAIN"
    print_status "Reloading DNS..."
    docker exec pihole pihole reloaddns
    print_success "DNS reloaded!"
else
    print_error "Failed to whitelist: $DOMAIN"
    exit 1
fi