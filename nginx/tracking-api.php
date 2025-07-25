<?php
// Tracking API endpoint for bigbraincoding.com
// This script handles the enhanced tracking data from JavaScript

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

// Get the raw POST data
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON data']);
    exit();
}

// Create log directory structure
$year = date('Y');
$month = date('m');
$day = date('d');
$logDir = "/var/www/bigbraincoding.com/logs/tracking/$year/$month";
$logFile = "$logDir/tracking_$day.json";

// Create directory if it doesn't exist
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

// Add server-side data
$data['server'] = [
    'timestamp' => time(),
    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
    'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
    'referer' => $_SERVER['HTTP_REFERER'] ?? 'unknown',
    'request_method' => $_SERVER['REQUEST_METHOD'],
    'content_type' => $_SERVER['CONTENT_TYPE'] ?? 'unknown'
];

// Add geolocation data if available
if (function_exists('geoip_record_by_name')) {
    $geo = geoip_record_by_name($data['server']['ip']);
    if ($geo) {
        $data['geolocation'] = [
            'country' => $geo['country_name'] ?? 'unknown',
            'region' => $geo['region'] ?? 'unknown',
            'city' => $geo['city'] ?? 'unknown',
            'latitude' => $geo['latitude'] ?? 'unknown',
            'longitude' => $geo['longitude'] ?? 'unknown'
        ];
    }
}

// Log the tracking data
$logEntry = json_encode($data) . "\n";
file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);

// Return success response
echo json_encode([
    'status' => 'success',
    'timestamp' => time(),
    'session_id' => $data['sessionId'] ?? 'unknown'
]);
?>