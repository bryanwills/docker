#!/bin/bash

# Supabase Docker Setup Script
# This script will help you set up Supabase with Docker Compose

set -e

echo "🚀 Supabase Docker Setup Script"
echo "================================"

# Check if we're in the right directory
if [ ! -f "docker/docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the supabase directory"
    echo "Current directory: $(pwd)"
    echo "Expected files: docker/docker-compose.yml"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if .env file exists
if [ -f ".env" ]; then
    echo "⚠️  Warning: .env file already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

echo "📋 Step 1: Creating .env file..."
cp docker/.env.example .env

echo "🔐 Step 2: Generating secure passwords and keys..."

# Generate secure passwords and keys
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
DASHBOARD_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
VAULT_ENC_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
LOGFLARE_PUBLIC=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
LOGFLARE_PRIVATE=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

echo "🔧 Step 3: Updating .env file with secure values..."

# Update the .env file with secure values
sed -i "s/your-super-secret-and-long-postgres-password/$POSTGRES_PASSWORD/g" .env
sed -i "s/your-super-secret-jwt-token-with-at-least-32-characters-long/$JWT_SECRET/g" .env
sed -i "s/this_password_is_insecure_and_should_be_updated/$DASHBOARD_PASSWORD/g" .env
sed -i "s/your-encryption-key-32-chars-min/$VAULT_ENC_KEY/g" .env
sed -i "s/your-super-secret-and-long-logflare-key-public/$LOGFLARE_PUBLIC/g" .env
sed -i "s/your-super-secret-and-long-logflare-key-private/$LOGFLARE_PRIVATE/g" .env

echo "📦 Step 4: Pulling Docker images..."
docker compose pull

echo "🚀 Step 5: Starting Supabase services..."
docker compose up -d

echo "⏳ Step 6: Waiting for services to be healthy..."
sleep 30

# Check if services are running
if docker compose ps | grep -q "running"; then
    echo "✅ Step 7: Services are starting up!"
    echo ""
    echo "🎉 Supabase is being set up!"
    echo "================================"
    echo ""
    echo "📊 Dashboard: http://localhost:8000"
    echo "👤 Username: supabase"
    echo "🔑 Password: $DASHBOARD_PASSWORD"
    echo ""
    echo "🗄️  Database:"
    echo "   Host: localhost"
    echo "   Port: 5432"
    echo "   Database: postgres"
    echo "   Username: postgres"
    echo "   Password: $POSTGRES_PASSWORD"
    echo ""
    echo "🔗 API Endpoints:"
    echo "   REST: http://localhost:8000/rest/v1/"
    echo "   Auth: http://localhost:8000/auth/v1/"
    echo "   Storage: http://localhost:8000/storage/v1/"
    echo "   Realtime: http://localhost:8000/realtime/v1/"
    echo ""
    echo "📝 Important Notes:"
    echo "   - Save these credentials securely!"
    echo "   - Services may take a few minutes to fully start"
    echo "   - Check status with: docker compose ps"
    echo "   - View logs with: docker compose logs"
    echo ""
    echo "🔧 Useful Commands:"
    echo "   Stop services: docker compose down"
    echo "   View logs: docker compose logs -f"
    echo "   Restart: docker compose restart"
    echo ""
else
    echo "❌ Error: Some services failed to start"
    echo "Check the logs with: docker compose logs"
    exit 1
fi

echo "✅ Setup complete! Supabase is starting up..."
echo "📖 For more information, see SETUP_GUIDE.md"