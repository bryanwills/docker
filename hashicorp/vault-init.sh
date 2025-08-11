#!/bin/sh

# Wait for Vault to be ready
echo "Waiting for Vault to start..."
sleep 15

# Set Vault address and token
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="${VAULT_DEV_ROOT_TOKEN_ID}"

echo "Configuring GitHub OAuth authentication..."

# Enable GitHub auth method
vault auth enable github 2>/dev/null || echo "GitHub auth already enabled"

# Configure GitHub auth for individual users (no organization)
vault write auth/github/config \
    base_url="https://api.github.com"

# Map your GitHub user to admin policy  
vault write auth/github/map/users/${GITHUB_USERNAME} value=default

# Disable userpass and token auth methods for security (keep only GitHub)
vault auth disable userpass 2>/dev/null || echo "Userpass not enabled"

echo "GitHub OAuth configuration complete!"
echo "You can now login with GitHub username: ${GITHUB_USERNAME}"
echo "Access at: https://keys.bryanwills.dev"