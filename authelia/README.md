# Authelia Container

Modern, secure authentication and authorization server for your infrastructure.

## �� Quick Start

1. **Create .env file:**
   ```bash
   # Copy .env.example to .env and update with your values
   cp .env.example .env

   # Generate secrets (optional - you can use any secure random strings)
   openssl rand -hex 32  # For JWT_SECRET
   openssl rand -hex 32  # For SESSION_SECRET
   openssl rand -hex 16  # For ENCRYPTION_KEY (32 characters)
   ```

2. **Generate admin password hash:**
   ```bash
   docker run --rm authelia/authelia:latest authelia crypto hash generate --password 'your_password'
   ```

3. **Update configuration files:**
   - `configuration/users_database.yml` - Update admin password hash
   - `.env` - Update with your JWT_SECRET and SESSION_SECRET

4. **Start the container:**
   ```bash
   docker compose up -d
   ```

5. **Access Authelia:**
   - **URL**: https://auth.bryanwills.dev
   - **Default User**: admin
   - **Default Password**: (set during setup)

## 🔧 Configuration

### Docker Compose
- **Image**: `docker.io/authelia/authelia:latest`
- **Port**: 9091 (internal)
- **Domain**: `auth.bryanwills.dev`
- **Network**: `proxy` (external)

### Traefik Integration
- **SSL**: Automatic via Let's Encrypt
- **Middleware**: Forward authentication for other services
- **Health Check**: Built-in health monitoring

### Security Features
- **2FA Support**: TOTP authentication
- **Password Policy**: Argon2id hashing
- **Session Management**: Secure cookie handling
- **Access Control**: Fine-grained policy rules

## 🛡️ Protecting Other Services

To protect other services with Authelia, add this middleware to their docker-compose.yml:

```yaml
labels:
  - "traefik.http.middlewares.authelia.forwardauth.address=http://authelia:9091/api/verify?rd=https://auth.bryanwills.dev"
  - "traefik.http.middlewares.authelia.forwardauth.trustForwardHeader=true"
  - "traefik.http.middlewares.authelia.forwardauth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Name,Remote-Email"
```

Then reference it in your service:
```yaml
- "traefik.http.routers.yourservice.middlewares=authelia@docker"
```

## 📁 File Structure

```
authelia/
├── docker-compose.yml          # Container configuration
├── configuration/
│   ├── configuration.yml       # Main Authelia config
│   └── users_database.yml     # User accounts
├── data/                       # Database and persistent data (gitignored)
│   └── .gitkeep               # Preserves directory structure
├── logs/                       # Log files (gitignored)
│   └── .gitkeep               # Preserves directory structure
├── setup-authelia.sh          # Setup helper script
└── README.md                  # This file
```

**Note**: The `data/` and `logs/` directories are ignored by git to prevent committing container data and logs.

## 🔐 Default Access Control

- **`auth.bryanwills.dev`**: Bypass (no authentication required)
- **`*.bryanwills.dev`**: One-factor authentication for admins and users
- **All other domains**: Denied by default

## 🚨 Security Notes

- **Never commit secrets** to git
- **Use strong passwords** for admin accounts
- **Regular updates** for security patches
- **Monitor logs** for suspicious activity
- **Backup configuration** and database files

## 📚 Documentation

- [Authelia Official Docs](https://www.authelia.com/)
- [Traefik Forward Auth](https://doc.traefik.io/traefik/middlewares/http/forwardauth/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

## 🆘 Troubleshooting

### Container won't start
- Check configuration syntax
- Verify secrets are properly set
- Check logs: `docker compose logs authelia`

### Can't access dashboard
- Verify Traefik labels are correct
- Check SSL certificate generation
- Verify network connectivity

### Authentication not working
- Check user database configuration
- Verify password hash generation
- Check access control rules
