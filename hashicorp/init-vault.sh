#!/bin/bash

# Wait for Vault to be ready
sleep 10

# Set environment variables
export VAULT_ADDR=http://0.0.0.0:8200
export VAULT_TOKEN=${VAULT_DEV_ROOT_TOKEN_ID}

# Enable authentication methods
vault auth enable github 2>/dev/null || echo "GitHub auth already enabled"
vault auth enable oidc 2>/dev/null || echo "OIDC auth already enabled"  
vault auth enable userpass 2>/dev/null || echo "Userpass auth already enabled"

# Configure GitHub user mapping
vault write auth/github/map/users/${VAULT_ADMIN_USERNAME} value=default

# Configure OIDC for GitHub OAuth
vault write auth/oidc/config \
    oidc_discovery_url="https://token.actions.githubusercontent.com" \
    oidc_client_id="${GITHUB_OAUTH_CLIENT_ID}" \
    oidc_client_secret="${GITHUB_OAUTH_CLIENT_SECRET}" \
    default_role="github"

vault write auth/oidc/role/github \
    bound_audiences="${GITHUB_OAUTH_CLIENT_ID}" \
    allowed_redirect_uris="https://keys.bryanwills.dev/ui/vault/auth/oidc/oidc/callback" \
    user_claim="sub" \
    policies="default"

# Create admin user
vault write auth/userpass/users/${VAULT_ADMIN_USERNAME} \
    password="${VAULT_ADMIN_PASSWORD}" \
    policies="default"

echo "Vault initialization complete!"