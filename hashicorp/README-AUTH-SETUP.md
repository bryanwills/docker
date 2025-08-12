# Vault Authentication Method Setup Guide

## 🚀 Quick Start

```bash
# Make the script executable
chmod +x setup-auth-method.sh

# Run the setup script
./setup-auth-method.sh
```

## 📋 What the Script Does

The script will guide you through:
1. **Selecting an authentication method**
2. **Choosing permission levels**
3. **Creating appropriate policies**
4. **Configuring the auth method**
5. **Setting up user mappings**

## 🔐 Available Authentication Methods

### 1. GitHub OAuth
- ✅ **Fully implemented**
- ✅ **Automatic user mapping**
- ✅ **Organization-based access**
- ✅ **OAuth flow with redirects**

### 2. Username/Password
- ✅ **Fully implemented**
- ✅ **Simple username/password login**
- ✅ **Good for service accounts**
- ✅ **Easy to manage**

### 3. OIDC (OpenID Connect)
- ⚠️ **Partially implemented**
- ✅ **Auth method enabled**
- ❌ **Requires manual configuration**
- 🔮 **Future enhancement planned**

### 4. LDAP
- ⚠️ **Partially implemented**
- ✅ **Auth method enabled**
- ❌ **Requires manual configuration**
- 🔮 **Future enhancement planned**

### 5. JWT
- ⚠️ **Partially implemented**
- ✅ **Auth method enabled**
- ❌ **Requires manual configuration**
- 🔮 **Future enhancement planned**

### 6. Custom
- ⚠️ **Partially implemented**
- ✅ **Auth method enabled**
- ❌ **Requires manual configuration**

## 🔑 Permission Levels

### 1. Super Admin
- **Full access to everything**
- **Can create/delete secret engines**
- **Full system access**
- **Equivalent to root token**

### 2. Admin
- **Access to most features**
- **Can manage secrets and engines**
- **Some system restrictions**
- **Good for administrators**

### 3. Power User
- **Full access to secrets**
- **Basic system information**
- **Token management**
- **Good for developers**

### 4. Standard User
- **Read/write access to secrets**
- **Basic token operations**
- **No system access**
- **Good for regular users**

### 5. Read Only
- **View secrets only**
- **No modifications allowed**
- **Basic token operations**
- **Good for auditors**

### 6. Custom
- **Not yet implemented**
- **Falls back to Super Admin**

## 🎯 Usage Examples

### Example 1: Add Another GitHub User
```bash
./setup-auth-method.sh
# Choose: 1 (GitHub OAuth)
# Choose: 1 (Super Admin)
# Enter policy name: github-super-admin-2
# Enter GitHub username: anotheruser
```

### Example 2: Add Username/Password Account
```bash
./setup-auth-method.sh
# Choose: 2 (Username/Password)
# Choose: 3 (Power User)
# Enter policy name: userpass-power-user
# Enter username: serviceaccount
# Enter password: securepassword
```

### Example 3: Prepare for OIDC (Future)
```bash
./setup-auth-method.sh
# Choose: 3 (OIDC)
# Choose: 1 (Super Admin)
# Enter policy name: oidc-super-admin
# Note: Will need manual configuration later
```

## 🔄 Adding New Users to Existing Methods

### For GitHub OAuth
```bash
# Map additional users to existing policies
vault write auth/github/map/users/newusername value=existing-policy-name
```

### For Username/Password
```bash
# Create additional users with existing policies
vault write auth/userpass/users/newusername \
    password="newpassword" \
    policies="existing-policy-name"
```

## 🚨 Important Notes

1. **Policy Updates**: When you update policies, existing users need ONE token refresh
2. **New Users**: Automatically get the specified permissions
3. **OIDC/LDAP/JWT**: Require additional configuration beyond this script
4. **Custom Methods**: May require manual setup

## 🔮 Future Enhancements

- [ ] **Full OIDC configuration**
- [ ] **Full LDAP configuration**
- [ ] **Full JWT configuration**
- [ ] **Custom policy builder**
- [ ] **Policy templates**
- [ ] **Bulk user import**

## 🆘 Troubleshooting

### "Permission denied" errors
- Check if the user has the right policy
- Verify the auth method is properly configured
- Ensure the user is mapped to the correct policy

### Auth method not working
- Check if the auth method is enabled
- Verify configuration parameters
- Check Vault logs for errors

### Policy not applying
- Users may need to refresh their tokens
- Verify policy syntax
- Check policy assignments
