# CLAUDE.md - AI Assistant Reference Document

**Last Updated:** November 2, 2025
**Project Status:** Initial setup complete, ready for Phase 1 development

---

## Quick Context

You're assisting Amanda with **Toasty**, a PowerShell-based notification filtering system for Windows Phone Link. This is the **prequel project** to a larger hardware project called **Blinky**.

### The Two Projects

**Toasty (Current)** - Software learning sandbox
- PowerShell script that monitors Windows Phone Link text messages
- Filters messages by keywords (lunch offers, emergencies, etc.)
- Displays custom toast notifications for matched messages
- Purpose: Learn Phone Link monitoring and text parsing **before** investing in hardware

**Blinky (Future)** - Hardware notification device
- ESP32 microcontroller with 0.32" OLED display and RGB LEDs
- Same monitoring/filtering as Toasty, but displays on physical device
- Color-coded alerts (red=emergency, green=food, blue=meetings)
- Google Calendar integration for meeting reminders
- Rails 8 backend for configuration and history
- 6 development phases spanning 5-11 months

### Why This Approach?

Amanda is de-risking the unknowns before hardware investment. The hardest part (monitoring Phone Link, text parsing) is proven in Toasty first. When transitioning to Blinky Phase 2, it's literally a 3-line change - swap toast notifications for HTTP POST to ESP32.

---

## Project Files Reference

### Essential Reading

1. **`/mnt/c/Users/Amanda Work/Downloads/blinky-project-plan.md`**
   - Complete roadmap for the hardware project
   - 6 phases with detailed checklists and time estimates
   - Security tiers, hardware specs, technology stack

2. **`/mnt/c/Users/Amanda Work/Downloads/powershell-toast-project-plan.md`**
   - Original plan for this prequel project (before rename to Toasty)
   - Development phases, success criteria, learning objectives
   - Repository structure and technical approach

### Text Parsing Strategy Discussion

A critical conversation happened about how to parse text messages for filtering:

**Initial plan:** Use regex with complex AND/OR patterns

**Considered alternative:** Google Natural Language API for sentiment/intent analysis

**Final decision:** Hybrid approach with weighted scoring
- NOT machine learning, just smart rule-based pattern matching
- PostgreSQL full-text search for fuzzy matching
- Confidence scores (0-1) instead of binary yes/no
- Time-based context clues (messages at 11am-2pm more likely lunch-related)
- Restaurant name detection
- Phrase matching ("want anything", "your usual", "food run")

**Key insight:** "Confidence score" is borrowed ML terminology, but this is just weighted rule-based logic, not actual AI/ML.

**Why not Google NLP API?**
- Overkill for simple keyword matching
- Adds external dependency and cost (~$1 per 1000 texts)
- Network latency (100-300ms per request)
- Less control over exact matching logic

---

## Repository Structure

```
toasty/
├── phone-monitor.ps1           # Main monitoring script (TODO: implement)
├── config.ps1                  # Configuration settings (complete)
├── filters.json                # Keyword definitions (initial filters ready)
├── test-notification.ps1       # Testing utility (TODO: implement)
├── README.md                   # Project documentation
├── LICENSE                     # MIT License
├── .gitignore                  # Excludes logs/ and sensitive data
├── CLAUDE.md                   # This file
├── docs/                       # Research and learnings (empty)
└── logs/                       # Notification logs (git-ignored)
```

---

## Current Status: Phase 0 Complete ✅

**What's done:**
- Repository created and initialized with git
- Project structure established
- Configuration files created
- Initial filters defined (Food Orders, Emergency)
- Documentation written

**Next steps:** Phase 1 - Research & Spike (3-6 hours estimated)
- Research Windows notification APIs
- Test if we can intercept Phone Link notifications
- Document findings in `docs/RESEARCH.md`
- Choose monitoring approach (Options A/B/C/D from project plan)
- Create basic skeleton script

---

## Development Philosophy & Preferences

### Amanda's Skill Level
- Comfortable with Rails 8, Ruby, JavaScript
- Learning PowerShell (this is a learning project!)
- New to hardware/embedded (ESP32 for Blinky later)
- Minimal AI/ML experience (did RLHF work, but not API integration)

### Communication Preferences
- **Capitalize project names in docs:** Toasty, Blinky (lowercase in code/repos)
- **Explain technical decisions:** Don't just show code, explain why
- **No AI buzzwords:** Use plain language (e.g., "weighted scoring" not "ML")
- **Transparency about complexity:** Realistic time estimates with 2-3x multipliers

### Code Preferences
- Simple solutions over clever ones
- Explicit over implicit
- Comments explaining the "why" not just "what"
- Configuration files (JSON) over hardcoded values

---

## Key Technical Decisions

### Phone Link Monitoring Approach (TBD)

Four options to investigate in Phase 1:

**Option A: Windows Notification Listener (Recommended first try)**
```powershell
Add-Type -AssemblyName Windows.UI
# Monitor toast notifications in real-time
```
✅ Real-time, catches everything
❌ More complex API, requires .NET knowledge

**Option B: Phone Link Log Files**
```powershell
# Monitor Phone Link's log directory, parse new entries
```
✅ Simpler file watching
❌ Uncertain if Phone Link logs to accessible files

**Option C: UI Automation (Fallback)**
```powershell
# Use UI Automation to "read" Phone Link window
```
✅ Definitely works
❌ Brittle, depends on UI structure

**Option D: Windows.Data.Notifications API (Most Proper)**
```powershell
# Official way to listen to notifications via UWP APIs
```
✅ Most "proper" approach
❌ Steepest learning curve

**Decision:** Start with Option A, document findings, fallback to Option C if needed.

### Text Filtering Strategy

**Implemented approach: Weighted pattern scoring**

```powershell
# LunchDetector.ps1 (conceptual - to be implemented)
$score = 0.0

# Strong signals (+0.5)
if ($text -match "want anything|your usual|food run") { $score += 0.5 }

# Medium signals (+0.3)
if ($text -match "heading to|going to get|order") { $score += 0.3 }

# Context clues
if ((Get-Date).Hour -ge 11 -and (Get-Date).Hour -le 14) { $score += 0.2 }

# Restaurant names (+0.3)
if ($text -match "chipotle|subway|pizza") { $score += 0.3 }

# Threshold decision
return $score -gt 0.5
```

Benefits:
- Easy to tune thresholds
- Can explain why something matched
- No external dependencies
- Fast execution

### Toast Notifications

Using **BurntToast** PowerShell module:
```powershell
Install-Module -Name BurntToast

New-BurntToastNotification `
    -Text "Food Order Detected!", "Message: want anything from chipotle?" `
    -AppLogo "C:\icon.png" `
    -Sound "Alarm"
```

---

## Filters Configuration

Current filters in `filters.json`:

### Food Orders (Green)
**Keywords:** lunch, food, delivery, order, pizza, chipotle, subway, want anything, your usual, food run, grab something, heading to

**Use case:** Coworkers offering lunch runs

### Emergency (Red)
**Keywords:** urgent, emergency, 911, asap, help, critical

**Use case:** Urgent notifications needing immediate attention

### General (Yellow, Disabled)
**Keywords:** (none)

**Use case:** Catch-all for unmatched notifications (disabled by default)

### Settings
- Case insensitive matching
- Partial match enabled
- Priority order: Emergency → Food Orders → General

---

## Transition Plan to Blinky

When Toasty proves the concept and Amanda starts Blinky Phase 2:

**Current (Toasty):**
```powershell
New-BurntToastNotification -Text $notificationText
```

**Future (Blinky Phase 2):**
```powershell
$body = @{
    message = $notificationText
    category = $matchedFilter
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://blinky.local/notify" `
    -Method Post -Body $body -ContentType "application/json"
```

The Toasty PowerShell code will be copied into `blinky/powershell/` directory when Blinky repository is created.

---

## Success Metrics for Toasty

Before moving to Blinky Phase 1 (hardware), Toasty must achieve:

✅ **Must-Have Features**
- Script detects Phone Link text notifications reliably
- Keyword filtering works (shows only matched notifications)
- Toast notifications appear with correct category/color
- Can run script in background continuously
- Logs all notifications for debugging
- Easy to add/edit filter keywords via config file
- Amanda feels comfortable with PowerShell scripting environment

⭐ **Bonus Features (Nice-to-Have)**
- Script auto-starts with Windows
- Pause/resume functionality
- Statistics tracking (notifications received vs filtered)
- Test notification generator for development

---

## Time Estimates

### Toasty Development
- **Phase 1:** Research & Spike (3-6 hours)
- **Phase 2:** Basic Monitoring (2-3 hours)
- **Phase 3:** Filtering Logic (2-3 hours)
- **Phase 4:** Toast Notifications (1-2 hours)
- **Phase 5:** Polish & Debug (2-4 hours)
- **Phase 6:** Documentation & Testing (1-2 hours)

**Total:** 11-20 hours base, 22-60 hours realistic (with 2-3x multiplier for learning curve, debugging, edge cases)

### Blinky Development (Future)
**Total:** 122-276 hours across 6 phases
- At 5-7 hrs/week: 20-46 weeks (~5-11 months)

---

## Important Context

### Why This Project Matters
Amanda wants to stay focused during deep work while not missing important notifications (lunch offers, emergencies, meeting reminders). The goal is a physical device (Blinky) that sits on the desk with color-coded alerts, but Toasty validates the hard parts first.

### Why "Toasty"?
Originally named "powershell-toast" but renamed to **Toasty** for:
- Better branding (companion to Blinky)
- Shorter and more memorable
- Consistent with Blinky's playful naming

### Learning Objectives
This isn't just about building a notification filter - it's about learning:
- PowerShell proficiency
- Windows APIs and notification systems
- Text processing and pattern matching
- System monitoring and background processes
- Configuration management

---

## Working with Amanda - Best Practices

1. **Explain your reasoning** - Don't just provide solutions, explain the trade-offs
2. **Use simple terminology** - Avoid unnecessary jargon (especially AI/ML terms)
3. **Realistic estimates** - Include 2-3x multipliers for unknowns
4. **Ask clarifying questions** - Amanda appreciates discussion before implementation
5. **Capitalize project names in documentation** - Toasty and Blinky (lowercase in filenames)
6. **Progressive complexity** - Start simple, add features incrementally
7. **Document discoveries** - Learning is part of the goal
8. **Work logs should be concise** - Daily work logs in `work_logs/` should be brief bird's-eye summaries, rarely exceeding 100 lines unless absolutely necessary

---

## Quick Reference Commands

```bash
# Navigate to project
cd ~/dev/toasty

# Run main monitor (when implemented)
pwsh phone-monitor.ps1

# Test with fake notification (when implemented)
pwsh test-notification.ps1 -Message "Want lunch?"

# View logs
cat logs/notifications.log

# Edit filters
nano filters.json
```

---

## Next Session Checklist

When you join a future session, check:

1. [ ] What phase is Toasty currently in?
2. [ ] Have any new docs been added to `docs/` folder?
3. [ ] Are there any open questions or blockers?
4. [ ] Has the transition to Blinky started yet?
5. [ ] Any new architectural decisions made?

Read this file first, then ask Amanda "Where are we in the Toasty journey?"

---

**Remember:** This is a learning project. The goal isn't just working code - it's Amanda understanding how it all works and feeling confident before moving to hardware.

Good luck! 🍞
