#!/bin/bash

# Script to create a secure non-root user for Vault CLI access
# This creates a user with appropriate permissions for managing secrets
# without giving full root access

set -e

# Configuration
VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-myroot}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}👤 Vault CLI User Creation Script${NC}"
echo "========================================"

# Check if Vault is accessible
if ! vault status >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: Cannot connect to Vault at $VAULT_ADDR${NC}"
    echo "Please ensure Vault is running and you're authenticated"
    exit 1
fi

# Create a policy for CLI users
echo -e "${BLUE}📋 Creating CLI user policy...${NC}"

vault policy write cli-user - <<EOF
# Policy for CLI users to manage secrets and basic operations
# This provides access to secrets without full admin privileges

# Allow full access to secrets
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to identity information
path "identity/*" {
  capabilities = ["read", "list"]
}

# Allow token operations for self
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow access to auth methods for listing
path "sys/auth" {
  capabilities = ["read"]
}

# Allow access to secret engines for listing
path "sys/mounts" {
  capabilities = ["read"]
}

# Allow access to policies for listing
path "sys/policies/acl" {
  capabilities = ["read", "list"]
}

# Allow access to audit logs
path "sys/audit" {
  capabilities = ["read", "list"]
}

# Allow access to health status
path "sys/health" {
  capabilities = ["read"]
}

# Allow access to seal status
path "sys/seal-status" {
  capabilities = ["read"]
}

# Allow access to leader status
path "sys/leader" {
  capabilities = ["read"]
}

# Allow access to replication status
path "sys/replication/*" {
  capabilities = ["read"]
}

# Allow access to plugins
path "sys/plugins/catalog/*" {
  capabilities = ["read", "list"]
}

# Allow access to tools
path "sys/tools/*" {
  capabilities = ["update"]
}

# Allow access to wrapping
path "sys/wrapping/*" {
  capabilities = ["update"]
}

# Allow access to control groups
path "sys/control-group/*" {
  capabilities = ["update"]
}

# Allow access to OIDC
path "identity/oidc/*" {
  capabilities = ["read", "list"]
}
EOF

echo -e "${GREEN}✅ CLI user policy created${NC}"

# Create a CLI user with username/password
echo -e "${BLUE}👤 Creating CLI user...${NC}"

# Generate a secure password
CLI_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

vault write auth/userpass/users/cli-user \
    password="$CLI_PASSWORD" \
    policies="cli-user" \
    ttl="24h" \
    max_ttl="168h" 2>/dev/null || echo "CLI user already exists"

echo -e "${GREEN}✅ CLI user created${NC}"

# Create a token for CLI access
echo -e "${BLUE}🔑 Creating CLI access token...${NC}"

CLI_TOKEN=$(vault token create -policy=cli-user -ttl=24h -format=json | jq -r '.auth.client_token')

if [ "$CLI_TOKEN" != "null" ] && [ -n "$CLI_TOKEN" ]; then
    echo -e "${GREEN}✅ CLI access token created${NC}"
else
    echo -e "${RED}❌ Failed to create CLI token${NC}"
    exit 1
fi

# Display the credentials
echo ""
echo -e "${GREEN}🎉 CLI User Setup Complete!${NC}"
echo "================================"
echo ""
echo -e "${BLUE}📋 User Credentials:${NC}"
echo "Username: cli-user"
echo "Password: $CLI_PASSWORD"
echo ""
echo -e "${BLUE}🔑 Access Token:${NC}"
echo "$CLI_TOKEN"
echo ""
echo -e "${BLUE}📁 Vault Configuration:${NC}"
echo "VAULT_ADDR=$VAULT_ADDR"
echo "VAULT_TOKEN=$CLI_TOKEN"
echo ""

# Create a configuration file
cat > vault-cli-config.env <<EOF
# Vault CLI Configuration
# Use these environment variables for CLI access
export VAULT_ADDR="$VAULT_ADDR"
export VAULT_TOKEN="$CLI_TOKEN"

# Or use this for username/password auth:
# export VAULT_USERNAME="cli-user"
# export VAULT_PASSWORD="$CLI_PASSWORD"
EOF

echo -e "${GREEN}📁 Configuration saved to: vault-cli-config.env${NC}"
echo ""
echo -e "${BLUE}📋 Usage Examples:${NC}"
echo "# Load the configuration:"
echo "source vault-cli-config.env"
echo ""
echo "# Test access:"
echo "vault kv list secret/"
echo ""
echo "# Or login with username/password:"
echo "vault login -method=userpass username=cli-user"
echo ""
echo -e "${YELLOW}⚠️  Security Notes:${NC}"
echo "- This token expires in 24 hours"
echo "- The password is randomly generated and shown only once"
echo "- Store these credentials securely"
echo "- Consider using GitHub OAuth for regular access"
echo "- This user cannot access root-level operations"
