#!/bin/bash

# Comprehensive Tracking Setup for bigbraincoding.com
# This script sets up all tracking components

set -e

echo "Setting up comprehensive tracking for bigbraincoding.com..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Create necessary directories
print_status "Creating directory structure..."

# Create logs directory structure
mkdir -p /home/bryanwi09/docker/nginx/logs/bigbraincoding.com
mkdir -p /home/bryanwi09/docker/nginx/sites
mkdir -p /home/bryanwi09/docker/nginx/www/bigbraincoding.com/logs/tracking

# Create year/month structure for current and next year
CURRENT_YEAR=$(date +%Y)
NEXT_YEAR=$((CURRENT_YEAR + 1))

for year in $CURRENT_YEAR $NEXT_YEAR; do
    for month in {01..12}; do
        mkdir -p "/home/bryanwi09/docker/nginx/logs/bigbraincoding.com/$year/$month"
        mkdir -p "/home/bryanwi09/docker/nginx/www/bigbraincoding.com/logs/tracking/$year/$month"
    done
done

# 2. Set proper permissions
print_status "Setting file permissions..."
sudo chown -R 101:101 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com
sudo chmod -R 755 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com

sudo chown -R 101:101 /home/bryanwi09/docker/nginx/www/bigbraincoding.com
sudo chmod -R 755 /home/bryanwi09/docker/nginx/www/bigbraincoding.com

# 3. Copy tracking files to website directory
print_status "Installing tracking components..."

# Copy tracking script to website
cp /home/bryanwi09/docker/nginx/tracking-script.js /home/bryanwi09/docker/nginx/www/bigbraincoding.com/
cp /home/bryanwi09/docker/nginx/tracking-api.php /home/bryanwi09/docker/nginx/www/bigbraincoding.com/

# 4. Update Docker Compose to include website volume
print_status "Updating Docker Compose configuration..."

# Check if website volume is already in docker-compose.yml
if ! grep -q "www" /home/bryanwi09/docker/nginx/docker-compose.yml; then
    # Add website volume to docker-compose.yml
    sed -i '/volumes:/a\      - ./www:/var/www' /home/bryanwi09/docker/nginx/docker-compose.yml
fi

# 5. Install logrotate configuration
print_status "Installing logrotate configuration..."
sudo cp /home/bryanwi09/docker/nginx/logrotate.conf /etc/logrotate.d/bigbraincoding.com

# 6. Create a simple index.html for testing
print_status "Creating test index.html..."
cat > /home/bryanwi09/docker/nginx/www/bigbraincoding.com/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Big Brain Coding - Software Development Company</title>
    <script src="/tracking-script.js"></script>
</head>
<body>
    <h1>Welcome to Big Brain Coding</h1>
    <p>Your software development partner</p>

    <h2>Services</h2>
    <ul>
        <li><a href="/services/web-development">Web Development</a></li>
        <li><a href="/services/mobile-apps">Mobile Apps</a></li>
        <li><a href="/services/consulting">Consulting</a></li>
    </ul>

    <button onclick="trackEvent('cta_click', {button: 'contact'})">Contact Us</button>

    <script>
        // Manual tracking example
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Tracking initialized for Big Brain Coding');
        });
    </script>
</body>
</html>
EOF

# 7. Create analytics dashboard script
print_status "Creating analytics dashboard..."
cat > /home/bryanwi09/docker/nginx/analytics-dashboard.php << 'EOF'
<?php
// Simple Analytics Dashboard for bigbraincoding.com
header('Content-Type: text/html; charset=utf-8');

$logDir = '/var/www/bigbraincoding.com/logs/tracking';
$accessLog = '/var/log/nginx/bigbraincoding.com/access.log';

function getLogStats($logFile) {
    if (!file_exists($logFile)) return [];

    $stats = [
        'total_requests' => 0,
        'unique_ips' => [],
        'user_agents' => [],
        'status_codes' => [],
        'referrers' => []
    ];

    $handle = fopen($logFile, 'r');
    while (($line = fgets($handle)) !== false) {
        $stats['total_requests']++;

        // Parse log line (simplified)
        if (preg_match('/^(\S+) - \S+ \[([^\]]+)\] "([^"]+)" (\d+) (\d+) "([^"]*)" "([^"]*)"/', $line, $matches)) {
            $ip = $matches[1];
            $status = $matches[4];
            $referrer = $matches[6];
            $userAgent = $matches[7];

            $stats['unique_ips'][$ip] = true;
            $stats['status_codes'][$status] = ($stats['status_codes'][$status] ?? 0) + 1;
            if ($referrer != '-') $stats['referrers'][$referrer] = ($stats['referrers'][$referrer] ?? 0) + 1;
            $stats['user_agents'][$userAgent] = ($stats['user_agents'][$userAgent] ?? 0) + 1;
        }
    }
    fclose($handle);

    return $stats;
}

$accessStats = getLogStats($accessLog);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics Dashboard - Big Brain Coding</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .stat-card { background: #f5f5f5; padding: 20px; border-radius: 8px; }
        .stat-number { font-size: 2em; font-weight: bold; color: #007cba; }
        .stat-label { color: #666; margin-top: 5px; }
    </style>
</head>
<body>
    <h1>Analytics Dashboard - Big Brain Coding</h1>
    <p>Last updated: <?php echo date('Y-m-d H:i:s'); ?></p>

    <div class="stats">
        <div class="stat-card">
            <div class="stat-number"><?php echo number_format($accessStats['total_requests'] ?? 0); ?></div>
            <div class="stat-label">Total Requests</div>
        </div>

        <div class="stat-card">
            <div class="stat-number"><?php echo count($accessStats['unique_ips'] ?? []); ?></div>
            <div class="stat-label">Unique IPs</div>
        </div>

        <div class="stat-card">
            <div class="stat-number"><?php echo count($accessStats['user_agents'] ?? []); ?></div>
            <div class="stat-label">Unique User Agents</div>
        </div>
    </div>

    <h2>Status Codes</h2>
    <ul>
    <?php foreach ($accessStats['status_codes'] ?? [] as $code => $count): ?>
        <li><?php echo $code; ?>: <?php echo $count; ?></li>
    <?php endforeach; ?>
    </ul>

    <h2>Top Referrers</h2>
    <ul>
    <?php
    $referrers = $accessStats['referrers'] ?? [];
    arsort($referrers);
    foreach (array_slice($referrers, 0, 10) as $referrer => $count):
    ?>
        <li><?php echo htmlspecialchars($referrer); ?>: <?php echo $count; ?></li>
    <?php endforeach; ?>
    </ul>
</body>
</html>
EOF

# 8. Set final permissions
print_status "Setting final permissions..."
sudo chown -R 101:101 /home/bryanwi09/docker/nginx/www/bigbraincoding.com
sudo chmod -R 755 /home/bryanwi09/docker/nginx/www/bigbraincoding.com

print_status "Setup complete! Here's what was configured:"
echo ""
echo "✅ Enhanced NGINX logging with detailed visitor information"
echo "✅ Organized log structure by year/month/day"
echo "✅ JavaScript tracking script for enhanced analytics"
echo "✅ PHP tracking API endpoint"
echo "✅ Log rotation with automatic organization"
echo "✅ Analytics dashboard at /analytics-dashboard.php"
echo ""
echo "📁 Log files location: /home/bryanwi09/docker/nginx/logs/bigbraincoding.com/"
echo "🌐 Website files: /home/bryanwi09/docker/nginx/www/bigbraincoding.com/"
echo "📊 Analytics: http://bigbraincoding.com/analytics-dashboard.php"
echo ""
print_warning "Don't forget to restart your NGINX container:"
echo "cd /home/bryanwi09/docker/nginx && docker-compose restart"