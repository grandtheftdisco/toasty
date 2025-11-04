# Test UserNotificationListener API
# This script tests if we can read Windows notifications using the official API
# Run this on Windows to verify the approach works before building the full monitor

Write-Host "=== Windows Notification Listener Test ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Load the WinRT API
Write-Host "[1/4] Loading Windows.UI.Notifications.Management API..." -ForegroundColor Yellow
try {
    [Windows.UI.Notifications.Management.UserNotificationListener, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    Write-Host "✅ API loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to load API: $_" -ForegroundColor Red
    Write-Host "Note: This must run on Windows 10/11 with PowerShell 5.1+" -ForegroundColor Red
    exit 1
}

# Step 2: Get the listener instance
Write-Host ""
Write-Host "[2/4] Getting UserNotificationListener instance..." -ForegroundColor Yellow
try {
    $listener = [Windows.UI.Notifications.Management.UserNotificationListener]::Current
    Write-Host "✅ Listener instance obtained" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get listener: $_" -ForegroundColor Red
    exit 1
}

# Step 3: Check permission status
Write-Host ""
Write-Host "[3/4] Checking notification access permission..." -ForegroundColor Yellow
try {
    $accessStatus = $listener.GetAccessStatus()
    Write-Host "Current access status: $accessStatus" -ForegroundColor Cyan

    if ($accessStatus -eq "Unspecified") {
        Write-Host "⚠️  Permission not yet requested. Requesting access..." -ForegroundColor Yellow
        Write-Host "   (You should see a Windows permission popup)" -ForegroundColor Gray

        # Request permission (this shows a popup to the user)
        $result = $listener.RequestAccessAsync().GetResults()
        Write-Host "   Permission result: $result" -ForegroundColor Cyan
        $accessStatus = $result
    }

    if ($accessStatus -eq "Allowed") {
        Write-Host "✅ Notification access is ALLOWED" -ForegroundColor Green
    } elseif ($accessStatus -eq "Denied") {
        Write-Host "❌ Notification access is DENIED" -ForegroundColor Red
        Write-Host "   Go to Settings > Privacy > Notifications to grant access" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "⚠️  Unknown access status: $accessStatus" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Failed to check permission: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Try to get notifications
Write-Host ""
Write-Host "[4/4] Fetching current notifications..." -ForegroundColor Yellow
try {
    # Get all toast notifications
    $notifications = $listener.GetNotificationsAsync([Windows.UI.Notifications.NotificationKinds]::Toast).GetResults()

    Write-Host "✅ Found $($notifications.Count) notification(s)" -ForegroundColor Green
    Write-Host ""

    if ($notifications.Count -eq 0) {
        Write-Host "💡 No notifications in Action Center. Try:" -ForegroundColor Cyan
        Write-Host "   1. Send yourself an SMS" -ForegroundColor Gray
        Write-Host "   2. Check notification appears in Action Center" -ForegroundColor Gray
        Write-Host "   3. Run this script again" -ForegroundColor Gray
    } else {
        # Display each notification
        $index = 1
        foreach ($notification in $notifications) {
            Write-Host "--- Notification #$index ---" -ForegroundColor Magenta

            # App info
            $appName = $notification.AppInfo.DisplayInfo.DisplayName
            Write-Host "  App: $appName" -ForegroundColor White

            # Notification ID
            Write-Host "  ID: $($notification.Id)" -ForegroundColor Gray

            # Try to get the notification content (it's XML)
            try {
                $content = $notification.Notification.Content
                $xml = [xml]$content.GetXml()

                # Extract text elements (basic parsing)
                $textElements = $xml.GetElementsByTagName("text")
                if ($textElements.Count -gt 0) {
                    Write-Host "  Content:" -ForegroundColor White
                    foreach ($text in $textElements) {
                        if ($text.InnerText) {
                            Write-Host "    - $($text.InnerText)" -ForegroundColor Gray
                        }
                    }
                }
            } catch {
                Write-Host "  (Could not parse notification content)" -ForegroundColor DarkGray
            }

            # Check if this is Phone Link
            if ($appName -match "Phone|YourPhone") {
                Write-Host "  🎯 THIS IS A PHONE LINK NOTIFICATION!" -ForegroundColor Green -BackgroundColor Black
            }

            Write-Host ""
            $index++
        }
    }
} catch {
    Write-Host "❌ Failed to get notifications: $_" -ForegroundColor Red
    Write-Host "   Error details: $($_.Exception.Message)" -ForegroundColor DarkRed
    exit 1
}

# Summary
Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ UserNotificationListener API works on this system!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Send yourself a test SMS to see Phone Link notifications" -ForegroundColor Gray
Write-Host "  2. Run this script again to verify we can read SMS content" -ForegroundColor Gray
Write-Host "  3. If it works, we'll build the full monitoring script!" -ForegroundColor Gray
Write-Host ""
