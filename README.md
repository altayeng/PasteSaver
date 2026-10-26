<p align="center">
  <img src="Resources/Logo/logo.png" width="128" alt="PasteSaver logo">
</p>

# PasteSaver

A lightweight clipboard history manager that lives in the macOS menu bar, built with Swift and SwiftUI.

## Features

- Keeps a history of copied text and images
- Search, pin and delete entries
- Click an entry to copy it back to the clipboard
- Ignores items marked as concealed by password managers
- Starts automatically at login
- History is stored locally and never leaves your Mac

## Requirements

- macOS 13 or later
- Swift 5.9 or later (Xcode 15+ or Command Line Tools)

## Build and install

```bash
bash scripts/build-app.sh --install
```

This builds a release binary, wraps it into `PasteSaver.app`, copies it to `/Applications` and launches it.
Run the script without `--install` to only produce `build/PasteSaver.app`.

On first launch PasteSaver registers itself as a login item. You can toggle this in the settings panel
(gear icon). Launch at login only works when running the bundled `.app`, not via `swift run`.

## Data location

History is stored in `~/Library/Application Support/PasteSaver`.

## Project structure

```
Sources/PasteSaver
├── main.swift                 Entry point
├── AppDelegate.swift          Status item and popover
├── Models/                    ClipboardItem
├── Services/                  Pasteboard access, monitoring, persistence, launch at login
└── Views/                     SwiftUI interface
```
