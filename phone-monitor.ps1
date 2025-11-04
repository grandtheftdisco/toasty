# Toasty - Phone Link Notification Monitor
# Main monitoring script that runs continuously
# Approach: UserNotificationListener API (Option D from research)

#Requires -Version 5.1

# Load configuration
. "$PSScriptRoot\config.ps1"

Write-Host "Toasty - Phone Link Notification Monitor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Helper Functions

function Load-Filters {
    # Load filter definitions from filters.json
    # Returns: Hashtable of filter configurations
    Write-Host "Loading filters from filters.json..." -ForegroundColor Gray

    # TODO Phase 2: Implement filter loading
    $filtersPath = Join-Path $PSScriptRoot "filters.json"
    if (-not (Test-Path $filtersPath)) {
        Write-Error "filters.json not found at $filtersPath"
        exit 1
    }

    # Parse JSON and return filters
    Write-Host "⚠️  Filter loading not yet implemented" -ForegroundColor Yellow
    return @{}
}

function Test-NotificationMatch {
    param(
        [string]$MessageText,
        [hashtable]$Filters
    )
    # Test if message matches any filter keywords
    # Returns: Matched filter name or $null

    # TODO Phase 3: Implement weighted pattern matching
    # See CLAUDE.md for scoring strategy
    return $null
}

function Show-ToastNotification {
    param(
        [string]$Title,
        [string]$Message,
        [string]$Category
    )
    # Display a Windows toast notification using BurntToast

    # TODO Phase 4: Implement with BurntToast module
    Write-Host "🔔 [TOAST] $Category: $Message" -ForegroundColor Green
}

function Write-NotificationLog {
    param(
        [string]$Sender,
        [string]$Message,
        [string]$MatchedFilter,
        [datetime]$Timestamp
    )
    # Log notification to logs/notifications.log

    # TODO Phase 5: Implement logging
    # Format: timestamp | sender | matched_filter | message_preview
}

#endregion

#region Notification Listener Setup

Write-Host "Initializing Windows notification listener..." -ForegroundColor Gray

# Step 1: Load WinRT API
try {
    [Windows.UI.Notifications.Management.UserNotificationListener, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    Write-Host "✅ UserNotificationListener API loaded" -ForegroundColor Green
} catch {
    Write-Error "Failed to load notification API. This requires Windows 10/11 with PowerShell 5.1+"
    Write-Error "Error: $_"
    exit 1
}

# Step 2: Get listener instance
try {
    $listener = [Windows.UI.Notifications.Management.UserNotificationListener]::Current
} catch {
    Write-Error "Failed to get notification listener instance: $_"
    exit 1
}

# Step 3: Check and request permissions
Write-Host "Checking notification access permissions..." -ForegroundColor Gray
$accessStatus = $listener.GetAccessStatus()

if ($accessStatus -eq "Unspecified") {
    Write-Host "⚠️  Requesting notification access permission..." -ForegroundColor Yellow
    Write-Host "   (Please allow access in the popup window)" -ForegroundColor Gray
    $accessStatus = $listener.RequestAccessAsync().GetResults()
}

if ($accessStatus -ne "Allowed") {
    Write-Error "Notification access denied. Please enable in Settings > Privacy > Notifications"
    exit 1
}

Write-Host "✅ Notification access granted" -ForegroundColor Green

#endregion

#region Load Configuration

$filters = Load-Filters

#endregion

#region Monitoring Loop

Write-Host ""
Write-Host "Starting notification monitor..." -ForegroundColor Cyan
Write-Host "Monitoring for Phone Link notifications. Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""

# Track processed notification IDs to avoid duplicates
$processedNotifications = @{}

try {
    while ($true) {
        # Get all toast notifications
        $notifications = $listener.GetNotificationsAsync([Windows.UI.Notifications.NotificationKinds]::Toast).GetResults()

        foreach ($notification in $notifications) {
            $notificationId = $notification.Id

            # Skip if we've already processed this notification
            if ($processedNotifications.ContainsKey($notificationId)) {
                continue
            }

            # Mark as processed
            $processedNotifications[$notificationId] = $true

            # Get app name
            $appName = $notification.AppInfo.DisplayInfo.DisplayName

            # Filter for Phone Link notifications only
            # Phone Link app names: "Phone Link", "YourPhone", "Your Phone"
            if ($appName -notmatch "Phone|YourPhone") {
                continue
            }

            # TODO Phase 2: Parse notification content XML
            # Extract sender and message text from notification.Notification.Content
            Write-Host "📱 Phone Link notification detected: $appName" -ForegroundColor Cyan
            Write-Host "   Notification ID: $notificationId" -ForegroundColor DarkGray

            # TODO Phase 3: Apply filter matching
            # $matchedFilter = Test-NotificationMatch -MessageText $messageText -Filters $filters

            # TODO Phase 4: Show toast if matched
            # if ($matchedFilter) {
            #     Show-ToastNotification -Title $matchedFilter -Message $messageText -Category $matchedFilter
            # }

            # TODO Phase 5: Log notification
            # Write-NotificationLog -Sender $sender -Message $messageText -MatchedFilter $matchedFilter -Timestamp (Get-Date)
        }

        # Clean up old processed notifications (keep last 100)
        if ($processedNotifications.Count -gt 100) {
            $keysToKeep = $processedNotifications.Keys | Select-Object -Last 100
            $newProcessed = @{}
            foreach ($key in $keysToKeep) {
                $newProcessed[$key] = $true
            }
            $processedNotifications = $newProcessed
        }

        # Poll every 2 seconds
        Start-Sleep -Seconds 2
    }
} catch {
    Write-Error "Monitoring loop error: $_"
} finally {
    Write-Host ""
    Write-Host "Monitor stopped." -ForegroundColor Yellow
}

#endregion
