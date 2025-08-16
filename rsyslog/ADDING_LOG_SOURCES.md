# Adding Log Sources to Centralized Logging System

This document provides step-by-step instructions for configuring various operating systems and distributions to send logs to the centralized logging server at `logs.bryanwills.dev:514`.

## Overview

The centralized logging system consists of:
- **Central Server**: `logs.bryanwills.dev:514` (UDP/TCP)
- **Log Aggregator**: Graylog running on `graylog.bryanwills.dev`
- **Protocols Supported**: UDP (port 514) and TCP (port 514)

## Prerequisites

- Network connectivity to `logs.bryanwills.dev:514`
- Administrative access to the source system
- Basic understanding of syslog configuration

---

## Debian/Ubuntu Systems

### Step 1: Install rsyslog (if not already installed)
```bash
sudo apt update
sudo apt install rsyslog
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /etc/rsyslog.conf
```

Add these lines at the top of the file (after the modules section):
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

### Step 3: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Restart rsyslog service
```bash
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

### Step 6: Verify configuration
```bash
sudo systemctl status rsyslog
sudo netstat -tlnp | grep 514
```

---

## Red Hat/CentOS/Rocky Linux Systems

### Step 1: Install rsyslog
```bash
sudo yum install rsyslog
# Or for newer versions:
sudo dnf install rsyslog
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /etc/rsyslog.conf
```

Add these lines at the top of the file (after the modules section):
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

### Step 3: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Restart rsyslog service
```bash
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

---

## Fedora Systems

### Step 1: Install rsyslog
```bash
sudo dnf install rsyslog
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /etc/rsyslog.conf
```

Add these lines at the top of the file (after the modules section):
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

### Step 3: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Restart rsyslog service
```bash
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

---

## Arch Linux Systems

### Step 1: Install rsyslog
```bash
sudo pacman -S rsyslog
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /etc/rsyslog.conf
```

Add these lines at the top of the file (after the modules section):
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

### Step 3: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Start and enable rsyslog service
```bash
sudo systemctl start rsyslog
sudo systemctl enable rsyslog
```

---

## Oracle Linux Systems

### Step 1: Install rsyslog
```bash
sudo yum install rsyslog
# Or for newer versions:
sudo dnf install rsyslog
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /etc/rsyslog.conf
```

Add these lines at the top of the file (after the modules section):
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

### Step 3: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Restart rsyslog service
```bash
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

---

## macOS Systems

### Method 1: Using built-in syslogd

#### Step 1: Create syslog configuration
```bash
sudo nano /etc/syslog.conf
```

#### Step 2: Add forwarding rule
```
*.* @logs.bryanwills.dev
```

#### Step 3: Restart syslogd
```bash
sudo launchctl bootout system/com.apple.syslogd
sudo launchctl bootstrap system /System/Library/LaunchDaemons/com.apple.syslogd.plist
```

### Method 2: Using Homebrew rsyslog (Recommended)

#### Step 1: Install rsyslog
```bash
brew install rsyslog
```

#### Step 2: Create configuration
```bash
sudo nano /usr/local/etc/rsyslog.conf
```

#### Step 3: Add forwarding rule with custom template
```conf
# Load modules
module(load="imudp")
module(load="imtcp")

# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat

# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

#### Step 4: Start rsyslog service
```bash
brew services start rsyslog
```

---

## Advanced Configuration Options

### Selective Log Forwarding

Instead of forwarding all logs (`*.*`), you can be selective:

```conf
# Forward only specific facilities
auth,authpriv.* @logs.bryanwills.dev:514;EnhancedForwardFormat
local0.* @logs.bryanwills.dev:514;EnhancedForwardFormat
local1.* @logs.bryanwills.dev:514;EnhancedForwardFormat

# Forward only specific priorities and above
*.info @logs.bryanwills.dev:514;EnhancedForwardFormat
*.warning @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### TCP vs UDP

- **UDP (`@`)**: Fast, lightweight, may lose messages
- **TCP (`@@`)**: Reliable, guaranteed delivery, slower

```conf
# UDP forwarding with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat

# TCP forwarding with enhanced template
*.* @@logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Custom Templates

For enhanced log information, use custom templates:

```conf
# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

---

## Troubleshooting

### Common Issues

#### 1. Connection Refused
```bash
# Test connectivity
nc -v logs.bryanwills.dev 514
telnet logs.bryanwills.dev 514
```

#### 2. Logs Not Appearing in Graylog
- Verify rsyslog service is running
- Check firewall settings
- Verify network connectivity
- Check Graylog input status

#### 3. Wrong Source IP (127.0.0.1)
- Check `/etc/hosts` file for localhost mappings
- Remove `%FROMHOST-IP%` from templates if using custom formatting
- Ensure proper hostname configuration
- Verify custom template configuration is applied

### Verification Commands

```bash
# Check rsyslog status
sudo systemctl status rsyslog

# Check rsyslog configuration
sudo rsyslogd -N1

# Check listening ports
sudo netstat -tlnp | grep 514

# Check rsyslog logs
sudo journalctl -u rsyslog -f

# Test log forwarding
logger -t "TestHost" "Test message from $(hostname)"
```

---

## Testing Configuration

### Step 1: Send test message
```bash
logger -t "TestHost" "Test message from $(hostname) at $(date)"
```

### Step 2: Check Graylog
- Navigate to `https://graylog.bryanwills.dev`
- Go to Search section
- Look for the test message
- Verify source information (hostname, IP, timestamp)

### Step 3: Verify log details
The log should show:
- **Source IP**: Actual network IP address
- **Hostname**: System hostname
- **Program**: `logger` or actual program name
- **Message**: Test message content
- **Timestamp**: When the message was sent

---

## Security Considerations

### Firewall Configuration
Ensure the source system can reach `logs.bryanwills.dev:514`:
```bash
# UFW (Ubuntu)
sudo ufw allow out 514

# iptables
sudo iptables -A OUTPUT -p udp --dport 514 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 514 -j ACCEPT
```

### Network Security
- Use internal networks when possible
- Consider VPN connections for remote systems
- Monitor for unauthorized log forwarding attempts

---

## Maintenance

### Regular Checks
- Monitor rsyslog service status
- Check for configuration errors
- Verify log forwarding is working
- Review firewall rules

### Updates
- Keep rsyslog updated
- Test configuration after system updates
- Backup custom configurations

---

## Support

For issues with the centralized logging system:
1. Check this documentation first
2. Verify network connectivity
3. Check rsyslog service status
4. Review system logs for errors
5. Contact system administrator

---

*Last Updated: August 15, 2025*
*Version: 1.1*
