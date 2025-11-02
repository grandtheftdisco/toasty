# Toasty Configuration
# Edit these settings to customize behavior

# Polling interval in seconds (how often to check for new notifications)
$PollingInterval = 5

# Log file location
$LogFile = "$PSScriptRoot\logs\notifications.log"

# Filters configuration file
$FiltersFile = "$PSScriptRoot\filters.json"

# Toast notification duration in seconds
$ToastDuration = 5

# Debug mode (more verbose logging)
$DebugMode = $true

# Ensure logs directory exists
if (-not (Test-Path "$PSScriptRoot\logs")) {
    New-Item -ItemType Directory -Path "$PSScriptRoot\logs" | Out-Null
}

Write-Host "Configuration loaded" -ForegroundColor Green
Write-Host "  Polling Interval: $PollingInterval seconds" -ForegroundColor Gray
Write-Host "  Log File: $LogFile" -ForegroundColor Gray
Write-Host "  Debug Mode: $DebugMode" -ForegroundColor Gray
