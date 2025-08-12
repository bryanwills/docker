# Admin policy for GitHub users - allows CLI access and most Vault features
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

path "auth/github/*" {
  capabilities = ["read", "list"]
}

# Allow enabling secret engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Allow access to most Vault features
path "*" {
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

# Allow access to policies
path "sys/policies/acl" {
  capabilities = ["read", "list"]
}

# Allow access to mounts
path "sys/mounts" {
  capabilities = ["read"]
}

# Allow access to audit logs
path "sys/audit" {
  capabilities = ["read", "list"]
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
