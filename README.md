<p align="center">
  <img src="icon.svg" width="80" height="80" alt="Cocaine icon">
</p>

<h1 align="center">Cocaine</h1>

<p align="center">
  <strong>Keep your Mac wired. Close the lid, keep it running.</strong>
</p>

<p align="center">
  <a href="https://github.com/Remenby31/cocaine/releases/latest"><img src="https://img.shields.io/github/v/release/Remenby31/cocaine" alt="Release"></a>
  <img src="https://img.shields.io/badge/macOS_13+-Apple%20Silicon-black?logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Swift-native-orange?logo=swift&logoColor=white" alt="Swift">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-orange" alt="MIT"></a>
</p>

---

A tiny menu bar app that prevents your Mac from sleeping — even when you close the lid. One click to toggle. No cloud, no bloat, no subscription. Just `caffeinate` + `pmset disablesleep` wrapped in a clean native UI.

## Why?

Tools like Caffeine and KeepingYouAwake prevent idle sleep, but your Mac still goes to sleep when you close the lid. Amphetamine handles it, but it's App Store only and full of features you don't need.

**Cocaine** does one thing: keeps your Mac awake no matter what. Toggle on, close the lid, walk away.

## Install

```bash
git clone https://github.com/Remenby31/cocaine.git
cd cocaine
bash build.sh            # builds + installs to /Applications
sudo bash setup-sudoers.sh   # one-time: allows pmset without password
open /Applications/Cocaine.app
```

## Usage

| Action | How |
|---|---|
| **Toggle** | Click the menu bar icon (left click) |
| **Menu** | Right-click the icon |
| **Start at Login** | Right-click → Start at Login |
| **Quit** | Right-click → Quit |

When active, the icon shows powder lines. When inactive, just the nose.

## How it works

When you activate Cocaine:
1. `sudo pmset -a disablesleep 1` — disables lid-close sleep
2. `caffeinate -di` — prevents idle and display sleep

When you deactivate (or quit):
1. Kills `caffeinate`
2. `sudo pmset -a disablesleep 0` — restores normal sleep behavior

The `setup-sudoers.sh` script adds a passwordless rule for `pmset` only, so the toggle is instant.

## Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon or Intel

## License

MIT
