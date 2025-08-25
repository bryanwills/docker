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

## FreeBSD/UNIX Systems

### Step 1: Install rsyslog
```bash
# Using pkg (recommended)
sudo pkg install rsyslog

# Or using ports
cd /usr/ports/sysutils/rsyslog
sudo make install clean
```

### Step 2: Configure main rsyslog.conf for custom templates
```bash
sudo nano /usr/local/etc/rsyslog.conf
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
sudo nano /usr/local/etc/rsyslog.d/forward-to-logs.conf
```

### Step 4: Add forwarding rule with custom template
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

### Step 5: Start and enable rsyslog service
```bash
# Add to rc.conf for automatic startup
echo 'rsyslogd_enable="YES"' | sudo tee -a /etc/rc.conf

# Start the service
sudo service rsyslogd start
```

### Step 6: Verify configuration
```bash
# Check if service is running
sudo service rsyslogd status

# Check listening ports
sockstat -l | grep 514
```

---

## NixOS Systems

### Step 1: Configure rsyslog in configuration.nix
```bash
sudo nano /etc/nixos/configuration.nix
```

Add this configuration:
```nix
{ config, pkgs, ... }:

{
  # Enable rsyslog
  services.rsyslog = {
    enable = true;
    extraConfig = ''
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
    '';
  };

  # Open firewall for outbound syslog
  networking.firewall = {
    allowedUDPPorts = [ 514 ];
    allowedTCPPorts = [ 514 ];
  };
}
```

### Step 2: Apply configuration
```bash
# Test configuration
sudo nixos-rebuild test

# If test is successful, apply permanently
sudo nixos-rebuild switch
```

### Step 3: Verify configuration
```bash
# Check service status
sudo systemctl status rsyslog

# Check configuration
sudo rsyslogd -N1

# Test log forwarding
logger -t "NixOS-Test" "Test message from NixOS at $(date)"
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

## Windows Systems

### Method 1: Using winget (Windows Package Manager - Recommended)

#### Step 1: Install rsyslog via winget
```powershell
# Open PowerShell as Administrator
winget install rsyslog
```

#### Step 2: Create rsyslog configuration directory
```powershell
# Create configuration directory
New-Item -ItemType Directory -Path "C:\Program Files\rsyslog\etc" -Force
```

#### Step 3: Create rsyslog configuration file
```powershell
# Create configuration file
New-Item -ItemType File -Path "C:\Program Files\rsyslog\etc\rsyslog.conf" -Force
```

#### Step 4: Edit configuration file
Add this content to `C:\Program Files\rsyslog\etc\rsyslog.conf`:
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

#### Step 5: Start rsyslog service
```powershell
# Start rsyslog service
Start-Service rsyslog

# Set service to start automatically
Set-Service rsyslog -StartupType Automatic
```

### Method 2: Using Chocolatey

#### Step 1: Install Chocolatey (if not already installed)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Step 2: Install rsyslog
```powershell
choco install rsyslog
```

#### Step 3: Configure as above (Method 1, Steps 2-5)

### Method 3: Using Scoop

#### Step 1: Install Scoop (if not already installed)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

#### Step 2: Install rsyslog
```powershell
scoop install rsyslog
```

#### Step 3: Configure as above (Method 1, Steps 2-5)

### Method 4: Using Windows Event Log Forwarding (Alternative)

#### Step 1: Configure Windows Event Collector
```powershell
# Enable Windows Event Collector service
wecutil qc /q

# Create subscription for forwarding events
wecutil cs "CentralizedLogging" /cm:Custom /d:"Forward logs to central server" /cf:"C:\temp\forwarder.xml" /ct:http /exp:2025-12-31T23:59:59Z
```

#### Step 2: Create forwarder configuration
Create `C:\temp\forwarder.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Subscription xmlns="http://schemas.microsoft.com/2006/03/windows/events/subscription">
  <SubscriptionId>CentralizedLogging</SubscriptionId>
  <Description>Forward logs to central server</Description>
  <Enabled>true</Enabled>
  <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
  <ConfigurationMode>Custom</ConfigurationMode>
  <Delivery Mode="Push">
    <PushSettings>
      <HeartbeatInterval>60000</HeartbeatInterval>
    </PushSettings>
  </Delivery>
  <Query>
    <![CDATA[
      <QueryList>
        <Query Id="0" Path="System">
          <Select Path="System">*</Select>
        </Query>
        <Query Id="1" Path="Application">
          <Select Path="Application">*</Select>
        </Query>
        <Query Id="2" Path="Security">
          <Select Path="Security">*</Select>
        </Query>
      </QueryList>
    ]]>
  </Query>
  <ReadExistingEvents>false</ReadExistingEvents>
  <TransportName>HTTP</TransportName>
  <ContentFormat>Events</ContentFormat>
  <Locale Language="en-US"/>
  <LogFile>ForwardedEvents</LogFile>
  <PublisherName>Microsoft-Windows-EventCollector</PublisherName>
</Subscription>
```

---

## WSL2 (Windows Subsystem for Linux) Integration

### Method 1: Forward WSL2 logs to central server

#### Step 1: Configure rsyslog in WSL2
```bash
# Install rsyslog in WSL2
sudo apt update
sudo apt install rsyslog

# Edit main configuration
sudo nano /etc/rsyslog.conf
```

Add these lines at the top:
```conf
# Preserve original source information
$PreserveFQDN on
$ActionForwardDefaultTemplate RSYSLOG_ForwardFormat

# Enhanced template with source information
$template EnhancedForwardFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% %PROGRAMNAME%[%PROCID%]: %msg%\n"

# Use enhanced template for forwarding
$ActionForwardDefaultTemplate EnhancedForwardFormat
```

#### Step 2: Create forwarding configuration
```bash
sudo nano /etc/rsyslog.d/forward-to-logs.conf
```

Add:
```conf
# Forward all logs to centralized logging server with enhanced template
*.* @logs.bryanwills.dev:514;EnhancedForwardFormat
```

#### Step 3: Restart rsyslog in WSL2
```bash
sudo systemctl restart rsyslog
sudo systemctl enable rsyslog
```

### Method 2: Forward Windows logs through WSL2

#### Step 1: Create PowerShell script for log forwarding
Create `C:\Scripts\forward-logs.ps1`:
```powershell
# Get Windows Event Logs and forward to rsyslog in WSL2
$events = Get-WinEvent -LogName System,Application -MaxEvents 100

foreach ($event in $events) {
    $message = "$($event.TimeCreated) $($event.LevelDisplayName) $($event.Source) $($event.Message)"
    # Send to WSL2 rsyslog which forwards to central server
    echo $message | wsl logger -t "Windows-EventLog"
}
```

#### Step 2: Set up scheduled task
```powershell
# Create scheduled task to run every 5 minutes
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\forward-logs.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 365)
$task = New-ScheduledTask -Action $action -Trigger $trigger -Description "Forward Windows logs to central server"

Register-ScheduledTask -TaskName "ForwardLogsToCentral" -InputObject $task
```

### Method 3: Direct WSL2 to Windows log forwarding

#### Step 1: Configure WSL2 to forward Windows events
In WSL2, create `/etc/rsyslog.d/windows-events.conf`:
```conf
# Forward Windows Event Logs through WSL2
# This requires Windows Event Log service to be accessible from WSL2

# Custom template for Windows events
$template WindowsEventFormat,"<%PRI%>%TIMESTAMP% %HOSTNAME% WindowsEventLog[%PROCID%]: %msg%\n"

# Forward Windows events to central server
*.* @logs.bryanwills.dev:514;WindowsEventFormat
```

---

## Windows Troubleshooting

### Common Issues

#### 1. Service Not Starting
```powershell
# Check service status
Get-Service rsyslog

# Check event logs for errors
Get-WinEvent -LogName Application | Where-Object {$_.Source -eq "rsyslog"}
```

#### 2. Firewall Issues
```powershell
# Allow rsyslog through Windows Firewall
New-NetFirewallRule -DisplayName "rsyslog Outbound" -Direction Outbound -Protocol UDP -RemotePort 514 -Action Allow
New-NetFirewallRule -DisplayName "rsyslog Outbound TCP" -Direction Outbound -Protocol TCP -RemotePort 514 -Action Allow
```

#### 3. WSL2 Network Issues
```bash
# In WSL2, check network connectivity
ping logs.bryanwills.dev
nc -v logs.bryanwills.dev 514

# Check WSL2 IP address
ip addr show eth0
```

### Verification Commands

#### Windows
```powershell
# Test log forwarding
Get-Service rsyslog | Select-Object Name, Status, StartType

# Check if service is listening
netstat -an | findstr :514
```

#### WSL2
```bash
# Test log forwarding
logger -t "WSL2-Test" "Test message from WSL2 at $(date)"

# Check rsyslog status
sudo systemctl status rsyslog
```

---

## Testing Windows/WSL2 Configuration

### Step 1: Send test message
```powershell
# Windows PowerShell
Write-EventLog -LogName Application -Source "TestSource" -EventId 1000 -EntryType Information -Message "Test message from Windows PowerShell"

# WSL2
logger -t "WSL2-Test" "Test message from WSL2 at $(date)"
```

### Step 2: Check Graylog
- Navigate to `https://graylog.bryanwills.dev`
- Go to Search section
- Look for test messages
- Verify source information shows Windows hostname and WSL2 hostname

### Step 3: Verify log details
Windows logs should show:
- **Source IP**: Windows machine IP address
- **Hostname**: Windows machine hostname
- **Program**: Windows Event Log or specific application
- **Message**: Event log message content
- **Timestamp**: When the event occurred

WSL2 logs should show:
- **Source IP**: WSL2 network interface IP
- **Hostname**: WSL2 hostname
- **Program**: `logger` or actual program name
- **Message**: Test message content
- **Timestamp**: When the message was sent

---

## Windows Security Considerations

### Firewall Configuration
```powershell
# Allow outbound connections to logs.bryanwills.dev:514
New-NetFirewallRule -DisplayName "Centralized Logging UDP" -Direction Outbound -Protocol UDP -RemoteAddress logs.bryanwills.dev -RemotePort 514 -Action Allow
New-NetFirewallRule -DisplayName "Centralized Logging TCP" -Direction Outbound -Protocol TCP -RemoteAddress logs.bryanwills.dev -RemotePort 514 -Action Allow
```

### Windows Defender
- Ensure Windows Defender allows rsyslog.exe
- Add rsyslog to Windows Defender exclusions if needed
- Monitor Windows Defender logs for blocked connections

### WSL2 Security
- Keep WSL2 updated
- Use WSL2 firewall rules if needed
- Monitor WSL2 network connections

---

## WSL2 Integration Benefits

### Advantages
- **Unified logging**: Both Windows and Linux logs in one place
- **Real-time forwarding**: WSL2 can forward logs as they occur
- **Rich metadata**: WSL2 provides detailed syslog information
- **Easy management**: Single configuration for both environments

### Use Cases
- **Development environments**: Forward application logs from WSL2
- **System monitoring**: Monitor both Windows and Linux services
- **Security auditing**: Track events across both operating systems
- **Compliance**: Meet logging requirements for mixed environments

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
logger -t "TestHost" "Test message from $(hostname)"
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
*Version: 1.3*
