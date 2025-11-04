# Phase 1 Research: Windows Notification Monitoring

**Date:** November 4, 2025
**Status:** Research complete, approach selected

---

## Research Question

How can we monitor Windows Phone Link notifications in real-time using PowerShell?

## Options Investigated

### Option A: Windows.UI Notification Listener ❌ (Rejected)

**Initial plan from CLAUDE.md:**
```powershell
Add-Type -AssemblyName Windows.UI
# Monitor toast notifications in real-time
```

**Findings:**
- Windows.UI doesn't contain notification *listener* APIs, only notification *creation* APIs
- The BurntToast module uses this assembly to **create** notifications, not monitor them
- This approach is for displaying toast notifications, not intercepting them

**Verdict:** Not viable for monitoring. Good for creating notifications (Phase 4).

---

### Option B: Windows Notification Database ⭐ (Viable Fallback)

**Approach:** Monitor the SQLite database where Windows stores notification history.

**Location:**
```
C:\Users\<username>\AppData\Local\Microsoft\Windows\Notifications\wpndatabase.db
```

**Database Structure:**
- SQLite database with `Notification` and `NotificationHandler` tables
- `Notification.Payload` column contains full notification text
- Supplemental files: `wpndatabase.db-wal` (write-ahead log), `wpndatabase.db-shm` (shared memory)

**Implementation Strategy:**
```powershell
# Monitor WAL file for changes, query new notifications
$dbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Notifications\wpndatabase.db"
# Use System.Data.SQLite to query database
# Watch file system for changes to trigger reads
```

**Pros:**
- ✅ Guaranteed to have all notification data
- ✅ Can access historical notifications
- ✅ Simpler API (just SQLite queries)
- ✅ No special permissions required

**Cons:**
- ❌ Database might be locked while Windows is writing
- ❌ Need to parse SQLite (requires PSSQLite module or .NET System.Data.SQLite)
- ❌ Polling-based (slight delay) rather than event-driven
- ❌ Need to track which notifications we've already processed

**Verdict:** Solid fallback if UserNotificationListener doesn't work.

---

### Option C: UI Automation ⚠️ (Last Resort)

**Approach:** Use UI Automation to read Phone Link window content.

**Why we're skipping this:**
- Brittle - breaks if Phone Link UI changes
- Requires Phone Link to be visible/running
- Complex to parse UI elements
- Notification might disappear before we read it

**Verdict:** Only consider if both Option B and D fail.

---

### Option D: UserNotificationListener API ⭐⭐ (RECOMMENDED)

**Approach:** Use the official Windows notification listener API via PowerShell WinRT interop.

**API Details:**
- Namespace: `Windows.UI.Notifications.Management.UserNotificationListener`
- Available since Windows 10 SDK 14393 (Anniversary Update)
- Can read all user notifications in real-time
- Provides structured notification data (not just text)

**PowerShell Implementation:**
```powershell
# Access WinRT API directly (no Add-Type needed!)
[Windows.UI.Notifications.Management.UserNotificationListener, Windows.UI.Notifications, ContentType = WindowsRuntime]
$listener = [Windows.UI.Notifications.Management.UserNotificationListener]::Current

# Request permission (first time only)
$accessStatus = $listener.RequestAccessAsync().GetResults()

# Check permission
switch($accessStatus) {
    "Allowed" {
        # Get current notifications
        $notifications = $listener.GetNotificationsAsync([Windows.UI.Notifications.NotificationKinds]::Toast).GetResults()
        foreach($notification in $notifications) {
            # Access notification properties
            $appDisplayName = $notification.AppInfo.DisplayInfo.DisplayName
            # Parse notification XML content
        }
    }
    "Denied" { Write-Warning "Notification access denied by user" }
    "Unspecified" { Write-Warning "Notification access status unknown" }
}
```

**Pros:**
- ✅ Official Microsoft API (most "proper" approach)
- ✅ Real-time access to notifications
- ✅ Structured data (app name, content, timestamp)
- ✅ Can filter by notification type (Toast, etc.)
- ✅ No polling required - can use async/await patterns
- ✅ Works with PowerShell 5.1 on Windows 10/11

**Cons:**
- ❌ Requires user permission (one-time popup)
- ❌ Steeper learning curve (WinRT APIs)
- ❌ Must parse XML notification payload
- ❌ Some reports of `GetAccessStatus()` quirks (always returns "Allowed" even when denied)

**Why this is best:**
1. **Future-proof:** Uses supported Windows APIs
2. **Reliable:** Won't break with Windows updates (unlike UI automation)
3. **Complete data:** Gets full notification structure, not just text
4. **Learning goal:** This teaches Windows API integration, which helps with Blinky later

**Verdict:** Start here. Fall back to Option B if permission issues can't be resolved.

---

## Phone Link Specific Considerations

**Phone Link App Name:**
- Modern: "Phone Link" or "YourPhone"
- Package: `Microsoft.YourPhone`

**Notification Format:**
- Phone Link sends notifications with sender name and message preview
- Likely includes notification actions (Reply, Dismiss)
- May truncate long messages in notification payload

**Testing Strategy:**
1. Send test SMS to paired phone
2. Use UserNotificationListener to enumerate all notifications
3. Find Phone Link notifications by app name
4. Parse message text from notification payload XML
5. Test with various message types (short, long, emoji, special characters)

---

## Implementation Plan

### Step 1: Proof of Concept (30 minutes)
Create `test-listener.ps1` to verify UserNotificationListener works:
- Request permission
- List all current notifications
- Find Phone Link notifications
- Print notification details

### Step 2: Real-Time Monitoring (1-2 hours)
Modify to continuously monitor:
- Poll GetNotificationsAsync() every 1-2 seconds
- Track notification IDs to avoid duplicates
- Extract sender and message text

### Step 3: Integration (30 minutes)
Move working code into `phone-monitor.ps1`:
- Load config.ps1
- Load filters.json
- Pass notifications to filter logic

### Step 4: Fallback Plan (if needed)
If UserNotificationListener permission issues are insurmountable:
- Implement Option B (database monitoring)
- Install PSSQLite module: `Install-Module -Name PSSQLite`
- Query database on file change events

---

## Required PowerShell Modules

**For Option D (UserNotificationListener):**
- None! WinRT APIs available in Windows PowerShell 5.1+

**For Option B (Database fallback):**
- PSSQLite: `Install-Module -Name PSSQLite -Scope CurrentUser`

**For Phase 4 (Toast notifications):**
- BurntToast: `Install-Module -Name BurntToast -Scope CurrentUser`

---

## Key Learnings

1. **WinRT in PowerShell:** You can access Windows Runtime APIs directly without Add-Type by using the `ContentType = WindowsRuntime` syntax

2. **Notification permissions:** Windows requires explicit user consent for notification access (good for privacy!)

3. **Database monitoring is viable:** Windows stores everything in SQLite, so worst case we can monitor the database

4. **Phone Link is just another app:** It uses standard Windows notification APIs, so we're not doing anything Phone Link-specific

---

## Next Steps

1. ✅ Research complete
2. ⏭️ Create proof-of-concept script to test UserNotificationListener
3. ⏭️ Test with actual Phone Link SMS notifications
4. ⏭️ Document any issues or discoveries
5. ⏭️ Build skeleton monitoring script

---

## References

- [UserNotificationListener Class - Microsoft Docs](https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.management.usernotificationlistener)
- [Notification listener - Windows apps](https://learn.microsoft.com/en-us/windows/apps/design/shell/tiles-and-notifications/notification-listener)
- [Windows 10 Notification Database Forensics](https://www.hecfblog.com/2018/08/daily-blog-440-windows-10-notifications.html)
- Stack Overflow: [Request notification permission through PowerShell](https://stackoverflow.com/questions/53211663/request-notification-permission-through-powershell)
