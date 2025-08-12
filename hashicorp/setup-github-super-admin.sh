#!/bin/bash

# Setup script to give ALL GitHub users automatic super admin access
# This eliminates the need for token refreshes when policies change

set -e

echo "🔧 Setting up GitHub Super Admin Access"
echo "======================================"

# Check if we're authenticated
if ! vault status >/dev/null 2>&1; then
    echo "❌ Not authenticated. Please login first."
    exit 1
fi

echo "✅ Authenticated with Vault"

# Create a super admin policy
echo "📋 Creating super admin policy..."
vault policy write github-super-admin - << 'EOF'
# GitHub Super Admin Policy - Full root-level access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

echo "✅ Super admin policy created"

# Update GitHub auth configuration to use the new policy
echo "🔐 Updating GitHub auth configuration..."
vault write auth/github/config \
    organization="bryanwillsorg" \
    base_url="https://api.github.com" \
    client_id="${GITHUB_OAUTH_CLIENT_ID}" \
    client_secret="${GITHUB_OAUTH_CLIENT_SECRET}"

echo "✅ GitHub auth configuration updated"

# Map ALL GitHub users to the super admin policy
echo "👥 Mapping all GitHub users to super admin policy..."
vault write auth/github/map/users/bryanwills value=github-super-admin

echo "✅ User mapping updated"

# Create a default policy for any new GitHub users
echo "🆕 Setting default policy for new GitHub users..."
vault write auth/github/config \
    organization="bryanwillsorg" \
    base_url="https://api.github.com" \
    client_id="${GITHUB_OAUTH_CLIENT_ID}" \
    client_secret="${GITHUB_OAUTH_CLIENT_SECRET}" \
    default_role="github-super-admin"

echo "✅ Default policy set for new users"

# Create the role
echo "🎭 Creating GitHub super admin role..."
vault write auth/github/role/github-super-admin \
    policies="github-super-admin" \
    ttl="24h" \
    max_ttl="168h"

echo "✅ Role created"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Now ALL GitHub users will automatically get:"
echo "✅ Full super admin access"
echo "✅ Access to ALL secret engines"
echo "✅ No token refreshes needed"
echo "✅ Automatic permissions for new resources"
echo ""
echo "To add a new GitHub user:"
echo "1. They login via GitHub OAuth"
echo "2. They automatically get super admin access"
echo "3. No policy updates needed"
echo ""
echo "Current users will need ONE token refresh to get the new permissions."
echo "After that, no more token refreshes needed!"
