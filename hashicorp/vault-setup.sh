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

# Configure GitHub OAuth (proper OAuth flow, not PAT-based)
vault write auth/github/config \
    organization="${GITHUB_ORGANIZATION}" \
    base_url="https://api.github.com" \
    client_id="${GITHUB_OAUTH_CLIENT_ID}" \
    client_secret="${GITHUB_OAUTH_CLIENT_SECRET}" 2>/dev/null || echo "GitHub OAuth config failed"

# Map GitHub users to policies
vault write auth/github/map/users/${GITHUB_USERNAME} value=admin 2>/dev/null || echo "GitHub user mapping failed"

# Create admin policy for GitHub users
vault policy write admin - <<EOF
# Admin policy for GitHub OAuth users
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "identity/*" {
  capabilities = ["read", "list"]
}

path "sys/auth/*" {
  capabilities = ["read", "list"]
}

path "auth/token/*" {
  capabilities = ["read", "list"]
}

# Allow access to most Vault features
path "*" {
  capabilities = ["read", "list"]
}
EOF

# Create a backup admin user (optional)
vault write auth/userpass/users/admin \
    password="${VAULT_DEV_ROOT_TOKEN_ID}" \
    policies="admin" 2>/dev/null || echo "Admin user creation failed"

# Create marker file to indicate configuration is complete
touch "$MARKER_FILE"
echo "Vault configuration complete!"
echo "Available auth methods: GitHub OAuth, Username/Password, Root Token"