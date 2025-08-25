#!/bin/bash

# Authelia Setup Script
# This script helps set up Authelia with proper configuration

set -e

echo "🔐 Authelia Setup Script"
echo "========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Configuration Steps:${NC}"
echo ""

echo -e "${YELLOW}1. Create .env file:${NC}"
echo "   Copy .env.example to .env and update with your values:"
echo "   - JWT_SECRET (64 character random string)"
echo "   - SESSION_SECRET (64 character random string)"
echo "   - ENCRYPTION_KEY (32 character random string for storage encryption)"
echo "   - ADMIN_PASSWORD (for password hash generation)"
echo ""

echo -e "${YELLOW}2. Generate Admin Password Hash:${NC}"
echo "   Run this command to generate a password hash:"
echo "   docker run --rm authelia/authelia:latest authelia crypto hash generate --password 'your_password'"
echo ""

echo -e "${YELLOW}3. Update Configuration Files:${NC}"
echo "   - Update configuration/users_database.yml with your password hash"
echo "   - The JWT_SECRET and SESSION_SECRET are now loaded from .env"
echo ""

echo -e "${YELLOW}4. Start Authelia:${NC}"
echo "   docker compose up -d"
echo ""

echo -e "${GREEN}✅ Setup instructions complete!${NC}"
echo ""
echo -e "${BLUE}📚 Next steps:${NC}"
echo "1. Generate the required secrets"
echo "2. Update the configuration files"
echo "3. Start the container"
echo "4. Access at https://auth.bryanwills.dev"
echo ""
echo -e "${YELLOW}⚠️  Security Note:${NC}"
echo "- Keep your .env file secure and never commit it to git"
echo "- Use strong, unique secrets for production"
echo "- Consider using external secret management for production"
