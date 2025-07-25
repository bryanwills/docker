# Comprehensive Visitor Tracking for bigbraincoding.com

This setup provides comprehensive visitor tracking for your `bigbraincoding.com` website using NGINX and JavaScript.

## 🎯 What This System Tracks

### **NGINX Server-Side Tracking:**
- ✅ IPv4/IPv6 addresses
- ✅ User-Agent strings
- ✅ Timestamp of visits
- ✅ Requested URLs/pages
- ✅ HTTP referrer
- ✅ Request method (GET, POST, etc.)
- ✅ Response status codes
- ✅ Response times
- ✅ File sizes transferred

### **JavaScript Client-Side Tracking:**
- ✅ Device type detection (mobile/desktop/tablet)
- ✅ Time spent on each page
- ✅ User interactions (clicks, scrolls)
- ✅ Session duration
- ✅ Page view counts per session
- ✅ Scroll depth tracking
- ✅ Form submissions
- ✅ Performance metrics

## 🚀 Quick Setup

### **1. Run the Setup Script**
```bash
cd /home/bryanwi09/docker/nginx
./setup-tracking.sh
```

### **2. Restart NGINX Container**
```bash
docker-compose restart
```

### **3. Add Tracking Script to Your Website**
Add this line to your website's `<head>` section:
```html
<script src="/tracking-script.js"></script>
```

## 📁 File Structure

```
nginx/
├── sites/
│   └── bigbraincoding.com.conf    # NGINX configuration
├── www/
│   └── bigbraincoding.com/
│       ├── index.html              # Test website
│       ├── tracking-script.js      # JavaScript tracking
│       ├── tracking-api.php        # PHP tracking endpoint
│       └── logs/
│           └── tracking/           # Organized tracking logs
├── logs/
│   └── bigbraincoding.com/        # NGINX access/error logs
│       └── YYYY/MM/               # Organized by date
├── setup-tracking.sh              # Setup script
├── logrotate.conf                 # Log rotation config
└── analytics-dashboard.php        # Analytics dashboard
```

## 📊 What You'll Get

### **NGINX Logs** (`/var/log/nginx/bigbraincoding.com/`)
- `access.log` - Detailed access logs with extended format
- `error.log` - Error logs
- Organized by year/month/day structure

### **Enhanced Tracking Logs** (`/var/www/bigbraincoding.com/logs/tracking/`)
- JSON-formatted tracking data
- Device information
- User interactions
- Performance metrics
- Session data

### **Analytics Dashboard**
- Real-time visitor statistics
- Top referrers
- Status code analysis
- Unique visitor counts

## 🔧 Configuration Details

### **NGINX Log Format**
The enhanced log format includes:
- Remote IP address
- Timestamp
- Request details
- Response status and size
- Referrer and User-Agent
- Response times
- Upstream information

### **JavaScript Tracking Features**
- **Session Management**: Automatic session creation and expiration
- **Device Detection**: Mobile, tablet, desktop identification
- **Performance Tracking**: Page load times, DOM ready times
- **Interaction Tracking**: Clicks, scrolls, form submissions
- **Session Analytics**: Time on page, session duration

## 📈 Analytics Dashboard

Access your analytics at: `http://bigbraincoding.com/analytics-dashboard.php`

The dashboard shows:
- Total requests
- Unique visitors
- Status code distribution
- Top referrers
- User agent statistics

## 🛠️ Manual Tracking

You can manually track events in your website code:

```javascript
// Track custom events
trackEvent('button_click', {button: 'contact', page: 'home'});

// Track page views
trackPageView();

// Track form submissions
trackEvent('form_submit', {form: 'contact', fields: 5});
```

## 🔍 Log Analysis

### **View Real-time Logs**
```bash
# NGINX access logs
tail -f /home/bryanwi09/docker/nginx/logs/bigbraincoding.com/access.log

# Enhanced tracking logs
tail -f /home/bryanwi09/docker/nginx/www/bigbraincoding.com/logs/tracking/$(date +%Y)/$(date +%m)/tracking_$(date +%d).json
```

### **Analyze Logs with Command Line**
```bash
# Count unique IPs
awk '{print $1}' access.log | sort | uniq | wc -l

# Top referrers
awk '{print $11}' access.log | sort | uniq -c | sort -nr | head -10

# Status code distribution
awk '{print $9}' access.log | sort | uniq -c | sort -nr
```

## 🔒 Privacy Considerations

### **Data Collected:**
- IP addresses (for analytics)
- User-Agent strings
- Page visit patterns
- Device information
- Performance metrics

### **Data NOT Collected:**
- Personal information
- Form data (unless explicitly tracked)
- Passwords or sensitive data

### **GDPR Compliance:**
- Consider adding a privacy policy
- Implement cookie consent if needed
- Provide opt-out mechanisms

## 🚨 Troubleshooting

### **Common Issues:**

1. **Permission Errors**
   ```bash
   sudo chown -R 101:101 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com
   sudo chmod -R 755 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com
   ```

2. **Container Won't Start**
   ```bash
   docker-compose logs nginx
   ```

3. **Tracking Not Working**
   - Check browser console for JavaScript errors
   - Verify tracking script is loaded
   - Check network tab for API calls

4. **Logs Not Organizing**
   ```bash
   sudo logrotate -f /etc/logrotate.d/bigbraincoding.com
   ```

## 📝 Customization

### **Modify Log Format**
Edit `sites/bigbraincoding.com.conf` and update the `log_format` directive.

### **Add Custom Tracking**
Modify `tracking-script.js` to add your own tracking events.

### **Custom Analytics**
Extend `analytics-dashboard.php` to show your specific metrics.

## 🎯 Marketing Use Cases

This tracking system helps you:

1. **Understand Your Audience**
   - Device types and browsers
   - Geographic distribution
   - Peak visit times

2. **Optimize User Experience**
   - Page performance metrics
   - User interaction patterns
   - Conversion funnel analysis

3. **Content Strategy**
   - Most popular pages
   - User engagement metrics
   - Content performance

4. **Technical Insights**
   - Error rates and types
   - Performance bottlenecks
   - Server response times

## 🔄 Maintenance

### **Daily Tasks:**
- Monitor log file sizes
- Check for errors in logs
- Review analytics dashboard

### **Weekly Tasks:**
- Analyze visitor patterns
- Review performance metrics
- Clean up old log files

### **Monthly Tasks:**
- Archive old logs
- Update tracking scripts
- Review privacy compliance

---

**Note:** This system provides comprehensive tracking while respecting user privacy. Always ensure compliance with relevant privacy laws and regulations.