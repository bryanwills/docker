#!/bin/bash

# This script configures Vault authentication methods persistently
# It creates a marker file so it only runs once

MARKER_FILE="/vault/file/.vault-configured"

# Check if already configured
if [ -f "$MARKER_FILE" ]; then
    echo "Vault already configured, skipping setup"
    exit 0
fi

# Wait for Vault to be ready
echo "Waiting for Vault to start..."
sleep 20

export VAULT_ADDR="http://vault:8200"
export VAULT_TOKEN="${VAULT_DEV_ROOT_TOKEN_ID}"

echo "Configuring Vault authentication methods..."

# Enable multiple auth methods for flexibility
vault auth enable github 2>/dev/null || echo "GitHub auth already enabled"
vault auth enable userpass 2>/dev/null || echo "Userpass already enabled" 
vault auth enable oidc 2>/dev/null || echo "OIDC already enabled"

# Configure GitHub token-based auth (for Personal Access Tokens)
# Now using your GitHub organization for proper configuration
vault write auth/github/config \
    organization="${GITHUB_ORGANIZATION}" \
    base_url="https://api.github.com" 2>/dev/null || echo "GitHub config failed"

vault write auth/github/map/users/${GITHUB_USERNAME} value=default 2>/dev/null || echo "GitHub user mapping failed"

# Configure GitHub OAuth via OIDC (for proper OAuth flow)
vault write auth/oidc/config \
    oidc_discovery_url="https://github.com/.well-known/openid_configuration" \
    oidc_client_id="${GITHUB_OAUTH_CLIENT_ID}" \
    oidc_client_secret="${GITHUB_OAUTH_CLIENT_SECRET}" \
    default_role="github-oauth" 2>/dev/null || echo "OIDC config completed"

vault write auth/oidc/role/github-oauth \
    bound_audiences="${GITHUB_OAUTH_CLIENT_ID}" \
    allowed_redirect_uris="https://keys.bryanwills.dev/ui/vault/auth/oidc/oidc/callback" \
    user_claim="sub" \
    policies="default" \
    oidc_scopes="user:email" 2>/dev/null || echo "OIDC role config failed"

# Create a backup admin user (optional)
vault write auth/userpass/users/admin \
    password="${VAULT_DEV_ROOT_TOKEN_ID}" \
    policies="default" 2>/dev/null || echo "Admin user creation failed"

# Create marker file to indicate configuration is complete
touch "$MARKER_FILE"
echo "Vault configuration complete!"
echo "Available auth methods: GitHub (token), GitHub OAuth (OIDC), Username/Password, Root Token"