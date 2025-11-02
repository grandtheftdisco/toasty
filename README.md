# Toasty 🍞

**PowerShell-based notification filtering system for Windows Phone Link**

A warmup project for learning Phone Link monitoring and notification filtering before building the Blinky hardware device.

## What is Toasty?

Toasty monitors Windows Phone Link text messages and displays custom toast notifications based on keyword filters. It's the software prequel to Blinky - validating the core filtering logic without hardware dependency.

## Project Status

🚧 **Planning Phase** - Repository initialized, ready to start development

## Features (Planned)

- ✅ Monitor Phone Link text notifications in real-time
- ✅ Keyword-based filtering with categories
- ✅ Custom toast notifications for matched messages
- ✅ JSON-based filter configuration
- ✅ Notification logging for debugging
- ✅ Background monitoring script

## Quick Start

*Coming soon - setup instructions will be added as development progresses*

## Why "Toasty"?

It's the prequel to Blinky! While Blinky will be a physical notification device with LEDs and a tiny screen, Toasty teaches us the hard parts (monitoring Phone Link, filtering text) using toast notifications.

## Project Structure

```
toasty/
├── phone-monitor.ps1           # Main monitoring script
├── filters.json                # Keyword definitions
├── config.ps1                  # Configuration settings
├── test-notification.ps1       # Testing utility
├── docs/                       # Research and learnings
└── logs/                       # Notification logs (git-ignored)
```

## The Journey Ahead

This project is Phase 1 of a larger vision. Once Toasty proves the monitoring and filtering logic works, the code will transition into Blinky Phase 2 - where instead of toast notifications, we'll send HTTP requests to an ESP32 device with LEDs and an OLED display.

## License

MIT License - See LICENSE file for details

---

**Created:** November 2, 2025
**Part of the Blinky Project**
