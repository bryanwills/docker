# GitHub Super Admin Policy - Automatically gives full access to any GitHub user
# This policy uses identity-based access control for automatic super admin permissions

# Full access to ALL secrets and secret engines (including newly created ones)
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "keys/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to ALL secret engines (including any new ones)
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to all auth methods
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to all policies
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to identity
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to ALL system paths
path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Full access to everything else - this is the key for root-level access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow token operations
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to plugins
path "sys/plugins/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to tools
path "sys/tools/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to wrapping
path "sys/wrapping/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to control groups
path "sys/control-group/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to audit
path "sys/audit/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to ha-status
path "sys/ha-status" {
  capabilities = ["read"]
}

# Allow access to leader
path "sys/leader" {
  capabilities = ["read"]
}

# Allow access to replication
path "sys/replication/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to all secret engines by name
path "sys/mounts" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to all auth methods by name
path "sys/auth" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
