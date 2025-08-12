#!/bin/bash

# Comprehensive Authentication Method Setup Script
# This script can set up any auth method with configurable permissions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Vault Authentication Method Setup${NC}"
echo "=========================================="
echo ""

# Check if we're authenticated
if ! vault status >/dev/null 2>&1; then
    echo -e "${RED}❌ Not authenticated. Please login first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Authenticated with Vault${NC}"
echo ""

# Function to select auth method
select_auth_method() {
    echo -e "${BLUE}📋 Available Authentication Methods:${NC}"
    echo "1) GitHub OAuth"
    echo "2) Username/Password"
    echo "3) OIDC (OpenID Connect)"
    echo "4) LDAP"
    echo "5) JWT"
    echo "6) Custom"
    echo ""

    read -p "Select authentication method (1-6): " -r choice
    echo ""

    case $choice in
        1) echo "github" ;;
        2) echo "userpass" ;;
        3) echo "oidc" ;;
        4) echo "ldap" ;;
        5) echo "jwt" ;;
        6)
            read -p "Enter custom auth method name: " -r custom_name
            echo "$custom_name" ;;
        *)
            echo -e "${RED}Invalid choice. Using GitHub OAuth.${NC}"
            echo "github" ;;
    esac
}

# Function to select permission level
select_permission_level() {
    echo -e "${BLUE}🔑 Permission Levels:${NC}"
    echo "1) Super Admin (Full access to everything)"
    echo "2) Admin (Access to most features, some restrictions)"
    echo "3) Power User (Access to secrets and basic features)"
    echo "4) Standard User (Basic access to secrets)"
    echo "5) Read Only (View only, no modifications)"
    echo "6) Custom (Define specific permissions)"
    echo ""

    read -p "Select permission level (1-6): " -r choice
    echo ""

    case $choice in
        1) echo "super-admin" ;;
        2) echo "admin" ;;
        3) echo "power-user" ;;
        4) echo "standard-user" ;;
        5) echo "read-only" ;;
        6) echo "custom" ;;
        *)
            echo -e "${RED}Invalid choice. Using Super Admin.${NC}"
            echo "super-admin" ;;
    esac
}

# Function to create policy based on permission level
create_policy() {
    local policy_name="$1"
    local permission_level="$2"

    echo -e "${BLUE}📋 Creating policy: $policy_name${NC}"

    case $permission_level in
        "super-admin")
            vault policy write "$policy_name" - << 'EOF'
# Super Admin Policy - Full root-level access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF
            ;;
        "admin")
            vault policy write "$policy_name" - << 'EOF'
# Admin Policy - Access to most features
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "keys/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/auth/*" {
  capabilities = ["read", "list"]
}
path "identity/*" {
  capabilities = ["read", "list"]
}
path "auth/token/*" {
  capabilities = ["read", "list"]
}
path "*" {
  capabilities = ["read", "list"]
}
EOF
            ;;
        "power-user")
            vault policy write "$policy_name" - << 'EOF'
# Power User Policy - Access to secrets and basic features
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "keys/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts" {
  capabilities = ["read"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF
            ;;
        "standard-user")
            vault policy write "$policy_name" - << 'EOF'
# Standard User Policy - Basic access to secrets
path "secret/*" {
  capabilities = ["read", "list"]
}
path "keys/*" {
  capabilities = ["read", "list"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF
            ;;
        "read-only")
            vault policy write "$policy_name" - << 'EOF'
# Read Only Policy - View only, no modifications
path "secret/*" {
  capabilities = ["read", "list"]
}
path "keys/*" {
  capabilities = ["read", "list"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF
            ;;
        "custom")
            echo -e "${YELLOW}⚠️  Custom policy creation not implemented yet${NC}"
            echo "Using Super Admin policy instead"
            create_policy "$policy_name" "super-admin"
            return
            ;;
    esac

    echo -e "${GREEN}✅ Policy created: $policy_name${NC}"
}

# Function to setup GitHub OAuth
setup_github_oauth() {
    local policy_name="$1"

    echo -e "${BLUE}🔐 Setting up GitHub OAuth...${NC}"

    # Check if GitHub auth is already enabled
    if ! vault auth list | grep -q "github/"; then
        echo "Enabling GitHub auth method..."
        vault auth enable github
    fi

    # Configure GitHub OAuth
    vault write auth/github/config \
        organization="${GITHUB_ORGANIZATION:-bryanwillsorg}" \
        base_url="https://api.github.com" \
        client_id="${GITHUB_OAUTH_CLIENT_ID}" \
        client_secret="${GITHUB_OAUTH_CLIENT_SECRET}"

    # Map users to policy
    read -p "Enter GitHub username to map: " -r github_username
    vault write auth/github/map/users/"$github_username" value="$policy_name"

    # Set default role for new users
    vault write auth/github/role/github-default \
        policies="$policy_name" \
        ttl="24h" \
        max_ttl="168h"

    echo -e "${GREEN}✅ GitHub OAuth configured${NC}"
}

# Function to setup Username/Password
setup_userpass() {
    local policy_name="$1"

    echo -e "${BLUE}👤 Setting up Username/Password...${NC}"

    # Check if userpass auth is already enabled
    if ! vault auth list | grep -q "userpass/"; then
        echo "Enabling userpass auth method..."
        vault auth enable userpass
    fi

    # Create user
    read -p "Enter username: " -r username
    read -s -p "Enter password: " -r password
    echo ""

    vault write auth/userpass/users/"$username" \
        password="$password" \
        policies="$policy_name"

    echo -e "${GREEN}✅ Username/Password user created${NC}"
}

# Function to setup OIDC
setup_oidc() {
    local policy_name="$1"

    echo -e "${BLUE}🔗 Setting up OIDC...${NC}"

    # Check if OIDC auth is already enabled
    if ! vault auth list | grep -q "oidc/"; then
        echo "Enabling OIDC auth method..."
        vault auth enable oidc
    fi

    echo -e "${YELLOW}⚠️  OIDC configuration requires additional setup${NC}"
    echo "This will be implemented in a future version"
    echo "For now, the auth method is enabled but not configured"

    echo -e "${GREEN}✅ OIDC auth method enabled${NC}"
}

# Function to setup LDAP
setup_ldap() {
    local policy_name="$1"

    echo -e "${BLUE}🏢 Setting up LDAP...${NC}"

    # Check if LDAP auth is already enabled
    if ! vault auth list | grep -q "ldap/"; then
        echo "Enabling LDAP auth method..."
        vault auth enable ldap
    fi

    echo -e "${YELLOW}⚠️  LDAP configuration requires additional setup${NC}"
    echo "This will be implemented in a future version"
    echo "For now, the auth method is enabled but not configured"

    echo -e "${GREEN}✅ LDAP auth method enabled${NC}"
}

# Function to setup JWT
setup_jwt() {
    local policy_name="$1"

    echo -e "${BLUE}🎫 Setting up JWT...${NC}"

    # Check if JWT auth is already enabled
    if ! vault auth list | grep -q "jwt/"; then
        echo "Enabling JWT auth method..."
        vault auth enable jwt
    fi

    echo -e "${YELLOW}⚠️  JWT configuration requires additional setup${NC}"
    echo "This will be implemented in a future version"
    echo "For now, the auth method is enabled but not configured"

    echo -e "${GREEN}✅ JWT auth method enabled${NC}"
}

# Main setup process
main() {
    echo -e "${BLUE}🚀 Starting authentication method setup...${NC}"
    echo ""

    # Get auth method
    auth_method=$(select_auth_method)
    echo -e "${GREEN}Selected: $auth_method${NC}"
    echo ""

    # Get permission level
    permission_level=$(select_permission_level)
    echo -e "${GREEN}Selected: $permission_level${NC}"
    echo ""

    # Create policy name
    read -p "Enter policy name (e.g., github-super-admin): " -r policy_name
    if [ -z "$policy_name" ]; then
        policy_name="${auth_method}-${permission_level}"
    fi

    echo -e "${GREEN}Policy name: $policy_name${NC}"
    echo ""

    # Create the policy
    create_policy "$policy_name" "$permission_level"
    echo ""

    # Setup the specific auth method
    case $auth_method in
        "github")
            setup_github_oauth "$policy_name"
            ;;
        "userpass")
            setup_userpass "$policy_name"
            ;;
        "oidc")
            setup_oidc "$policy_name"
            ;;
        "ldap")
            setup_ldap "$policy_name"
            ;;
        "jwt")
            setup_jwt "$policy_name"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Custom auth method setup not implemented yet${NC}"
            echo "The auth method is enabled but you'll need to configure it manually"
            ;;
    esac

    echo ""
    echo -e "${GREEN}🎉 Setup Complete!${NC}"
    echo "========================"
    echo ""
    echo -e "${BLUE}📋 Summary:${NC}"
    echo "Auth Method: $auth_method"
    echo "Policy: $policy_name"
    echo "Permission Level: $permission_level"
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo "1. Test the new authentication method"
    echo "2. Users can now login and get the specified permissions"
    echo "3. No more token refreshes needed for policy changes"
    echo ""
    echo -e "${YELLOW}⚠️  Note:${NC}"
    echo "- Current users may need one token refresh to get new permissions"
    echo "- New users will automatically get the specified permissions"
    echo "- OIDC, LDAP, and JWT require additional configuration"
}

# Run the main function
main
