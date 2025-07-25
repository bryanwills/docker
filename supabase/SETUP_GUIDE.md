# Supabase Docker Setup Guide

This guide will walk you through setting up Supabase using Docker Compose on your local machine.

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB of RAM available
- Ports 8000, 5432, 6543, 4000 available

## Step 1: Navigate to the Supabase Directory

```bash
cd ~/docker/supabase
```

## Step 2: Create Environment File

Create a `.env` file in the supabase directory with the following content:

```bash
cp docker/.env.example .env
```

## Step 3: Update Critical Security Variables

**IMPORTANT**: You must change these default values for security:

### Required Password Changes:

1. **POSTGRES_PASSWORD**: Change from `your-super-secret-and-long-postgres-password` to a strong password
2. **JWT_SECRET**: Change from `your-super-secret-jwt-token-with-at-least-32-characters-long` to a strong 32+ character secret
3. **DASHBOARD_PASSWORD**: Change from `this_password_is_insecure_and_should_be_updated` to a strong password
4. **VAULT_ENC_KEY**: Change from `your-encryption-key-32-chars-min` to a 32-character encryption key

### Example Secure Configuration:

```env
POSTGRES_PASSWORD=supabase_secure_password_2024
JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters-long-2024
DASHBOARD_PASSWORD=supabase_secure_dashboard_password_2024
VAULT_ENC_KEY=your-encryption-key-32-chars-min-2024
```

## Step 4: Generate Secure Keys (Optional but Recommended)

### Generate JWT Secret:
```bash
openssl rand -base64 32
```

### Generate Vault Encryption Key:
```bash
openssl rand -base64 32
```

### Generate Logflare Tokens:
```bash
openssl rand -base64 32
```

## Step 5: Update .env File

Edit the `.env` file and replace the placeholder values with your generated secure values.

## Step 6: Start Supabase Services

```bash
# Pull the latest images
docker compose pull

# Start all services in detached mode
docker compose up -d
```

## Step 7: Verify Services are Running

```bash
# Check service status
docker compose ps

# All services should show "running (healthy)" status
```

## Step 8: Access Supabase

### Supabase Studio (Dashboard)
- URL: http://localhost:8000
- Username: `supabase` (or your custom DASHBOARD_USERNAME)
- Password: Your DASHBOARD_PASSWORD value

### API Endpoints
- REST API: http://localhost:8000/rest/v1/
- Auth API: http://localhost:8000/auth/v1/
- Storage API: http://localhost:8000/storage/v1/
- Realtime API: http://localhost:8000/realtime/v1/

### Database Connection
- Host: localhost
- Port: 5432
- Database: postgres
- Username: postgres
- Password: Your POSTGRES_PASSWORD value

## Step 9: Development Mode (Optional)

For development with additional services like mail testing:

```bash
docker compose -f docker-compose.yml -f dev/docker-compose.dev.yml up -d
```

This adds:
- Mail testing service on port 2500
- Database seeding with sample data
- Additional development configurations

## Step 10: Security Recommendations

### 1. Change Default Credentials
- Update all passwords in the `.env` file
- Use strong, unique passwords for each service

### 2. Network Security
- Consider using a reverse proxy (like Traefik) for production
- Set up SSL/TLS certificates
- Configure firewall rules

### 3. Database Security
- Change the default postgres password
- Consider using external PostgreSQL for production
- Enable SSL connections

### 4. Email Configuration
For production, configure a real SMTP server:

```env
SMTP_ADMIN_EMAIL=your-email@domain.com
SMTP_HOST=your-smtp-server.com
SMTP_PORT=587
SMTP_USER=your-smtp-username
SMTP_PASS=your-smtp-password
SMTP_SENDER_NAME=Your App Name
```

## Troubleshooting

### Common Issues:

1. **Port Conflicts**: Ensure ports 8000, 5432, 6543, 4000 are available
2. **Memory Issues**: Ensure Docker has at least 4GB RAM allocated
3. **Permission Issues**: Check Docker socket permissions
4. **Service Health Checks**: If services aren't healthy, check logs:

```bash
# View logs for specific service
docker compose logs <service-name>

# View all logs
docker compose logs
```

### Reset Everything:
```bash
./docker/reset.sh
```

## Service Architecture

Supabase consists of these main services:

- **Kong**: API Gateway (port 8000)
- **PostgreSQL**: Database (port 5432)
- **GoTrue**: Authentication service
- **PostgREST**: REST API
- **Realtime**: WebSocket service
- **Storage**: File storage service
- **Studio**: Web dashboard
- **Functions**: Edge functions
- **Analytics**: Logging and analytics
- **Supavisor**: Connection pooler (port 6543)

## Next Steps

1. **Explore the Dashboard**: Access http://localhost:8000 and explore the features
2. **Create Your First Project**: Use the Studio to create tables and APIs
3. **Integrate with Your App**: Use the provided API keys to connect your application
4. **Set Up Authentication**: Configure email providers and OAuth settings
5. **Deploy to Production**: Follow production deployment guides for security hardening

## Useful Commands

```bash
# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes all data)
docker compose down -v

# View logs
docker compose logs -f

# Restart specific service
docker compose restart <service-name>

# Update to latest images
docker compose pull && docker compose up -d
```

## Environment Variables Reference

### Critical Security Variables:
- `POSTGRES_PASSWORD`: Database password
- `JWT_SECRET`: JWT signing secret (32+ chars)
- `ANON_KEY`: Public API key
- `SERVICE_ROLE_KEY`: Admin API key
- `DASHBOARD_PASSWORD`: Studio login password
- `SECRET_KEY_BASE`: Application secret
- `VAULT_ENC_KEY`: Encryption key (32 chars)

### Database Configuration:
- `POSTGRES_HOST`: Database host (usually 'db')
- `POSTGRES_DB`: Database name (usually 'postgres')
- `POSTGRES_PORT`: Database port (usually 5432)

### API Configuration:
- `KONG_HTTP_PORT`: API gateway port (usually 8000)
- `PGRST_DB_SCHEMAS`: Database schemas for REST API

### Authentication Configuration:
- `SITE_URL`: Your application URL
- `API_EXTERNAL_URL`: External API URL
- `JWT_EXPIRY`: JWT token expiry time
- `DISABLE_SIGNUP`: Disable user signups
- `ENABLE_EMAIL_SIGNUP`: Enable email signups
- `ENABLE_PHONE_SIGNUP`: Enable phone signups

### Email Configuration:
- `SMTP_HOST`: SMTP server host
- `SMTP_PORT`: SMTP server port
- `SMTP_USER`: SMTP username
- `SMTP_PASS`: SMTP password
- `SMTP_ADMIN_EMAIL`: Admin email address

### Studio Configuration:
- `STUDIO_DEFAULT_ORGANIZATION`: Default org name
- `STUDIO_DEFAULT_PROJECT`: Default project name
- `SUPABASE_PUBLIC_URL`: Public Supabase URL

### Analytics Configuration:
- `LOGFLARE_PUBLIC_ACCESS_TOKEN`: Public analytics token
- `LOGFLARE_PRIVATE_ACCESS_TOKEN`: Private analytics token
- `DOCKER_SOCKET_LOCATION`: Docker socket path

## Production Considerations

1. **Use External PostgreSQL**: For production, consider using a managed PostgreSQL service
2. **Set Up Monitoring**: Implement proper logging and monitoring
3. **Backup Strategy**: Set up regular database backups
4. **SSL/TLS**: Configure SSL certificates for all endpoints
5. **Rate Limiting**: Implement rate limiting on the API gateway
6. **Secrets Management**: Use a secrets manager instead of .env files
7. **High Availability**: Consider running multiple instances for redundancy

## Support

- [Supabase Documentation](https://supabase.com/docs)
- [GitHub Issues](https://github.com/supabase/supabase/issues)
- [Discord Community](https://discord.supabase.com/)