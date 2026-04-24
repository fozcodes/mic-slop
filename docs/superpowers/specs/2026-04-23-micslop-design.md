# MicSlop Design Spec

## Overview

macOS menu bar app that toggles system input volume between 0 and 50 via global hotkey, with visual "ON AIR" / "OFF AIR" status indicator.

## Requirements

- **Toggle**: Cmd+L toggles input volume between 0 and 50
- **Status display**: Menu bar shows colored label
  - Red background + white "ON AIR" when volume > 0
  - Grey background + white "OFF AIR" when volume = 0
- **External changes**: Poll system volume every 60 seconds to catch changes made outside the app
- **Menu**: Click status bar item shows menu with Quit option only
- **Launch at login**: Enabled by default via SMAppService
- **No dock icon**: App runs as LSUIElement (menu bar only)

## Architecture

```
MicSlopApp (SwiftUI App)
├── AppDelegate
│   ├── NSStatusItem (menu bar)
│   ├── HotKey listener (Cmd+L)
│   └── SMAppService (launch at login)
├── StatusBarView (SwiftUI)
│   └── "ON AIR" / "OFF AIR" label
├── AudioController
│   ├── NSAppleScript volume control
│   └── Timer (60s polling)
└── Menu
    └── Quit item only
```

## Components

### StatusBarView

SwiftUI view rendering colored rectangle with text:
- Red background (#FF3B30 or similar) + white "ON AIR" when volume > 0
- Grey background (#8E8E93 or similar) + white "OFF AIR" when volume = 0
- Compact sizing appropriate for menu bar

### AudioController

Wrapper around NSAppleScript for volume control:
- `@Published var volume: Int` - current input volume (0-100)
- `func toggle()` - if volume > 0, set to 0; else set to 50
- `func refresh()` - read current system input volume
- Calls `refresh()` on init to get initial state
- Timer fires every 60 seconds calling `refresh()`

AppleScript commands:
- Get: `input volume of (get volume settings)`
- Set: `set volume input volume X`

### AppDelegate

- Creates and owns NSStatusItem
- Sets up HotKey (Cmd+L) via sindresorhus/HotKey package
- Registers launch-at-login via SMAppService.mainApp
- Connects AudioController to StatusBarView

## Data Flow

```
Sources of state change:
  1. Cmd+L pressed → AudioController.toggle() → volume updates → UI re-renders
  2. Timer fires (60s) → AudioController.refresh() → volume updates if changed → UI re-renders

Binding:
  StatusBarView observes AudioController.volume
  Displays "ON AIR" if volume > 0, "OFF AIR" if volume == 0
```

## Dependencies

- **HotKey** (sindresorhus/HotKey via SPM) - global keyboard shortcut
- macOS 13+ (for SMAppService)

## File Structure

```
MicSlop/
├── Package.swift              # SPM manifest with HotKey dependency
├── Sources/
│   └── MicSlop/
│       ├── MicSlopApp.swift       # App entry point, AppDelegate setup
│       ├── StatusBarView.swift    # ON AIR / OFF AIR SwiftUI view
│       └── AudioController.swift  # Volume control + polling timer
└── Info.plist                 # LSUIElement=true, other app metadata
```

## Error Handling

- AppleScript failure: Log error, don't crash. UI shows last known state.
- No special permissions needed for volume control via AppleScript

## Build & Run

- Build with `swift build` or open in Xcode
- Run from command line or Xcode
- For distribution: archive and notarize (requires Apple Developer account)

## Future Considerations (Out of Scope)

- Configurable hotkey
- Configurable volume level (currently hardcoded to 50)
- Multiple audio device support
