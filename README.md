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

A tiny native menu bar app that prevents your Mac from sleeping — **even when you close the lid**. Built for developers running AI agents (Claude Code, Cursor, Codex, Aider...) who need their sessions to survive a closed laptop.

Toss your MacBook in your backpack, tether to your phone, and let your agents finish the job on the commute home.

## Why?

You're running a long Claude Code session. You need to leave. You close your Mac and... everything dies.

- **Caffeine / KeepingYouAwake** only prevent idle sleep — closing the lid still kills your session
- **Amphetamine** handles it, but it's App Store only and bloated with features you don't need
- **`caffeinate`** alone doesn't prevent lid-close sleep

**Cocaine** does one thing: keeps your Mac awake no matter what. Toggle on, close the lid, walk away. Your agents keep running.

## Install

```bash
git clone https://github.com/Remenby31/cocaine.git
cd cocaine
bash build.sh                # builds + installs to /Applications
sudo bash setup-sudoers.sh   # one-time: allows pmset without password
open /Applications/Cocaine.app
```

The app auto-activates on launch and starts at login via LaunchAgent.

## Usage

| Action | How |
|---|---|
| **Toggle** | Left-click the menu bar icon |
| **Menu** | Right-click the icon |
| **Quit** | Right-click → Quit |

When active, the icon shows the tube snorting powder lines. When inactive, the tube is lying flat.

## How it works

When you activate Cocaine:

1. **`sudo pmset -a disablesleep 1`** — disables lid-close sleep at the OS level
2. **`caffeinate -di`** — prevents idle and display sleep

When you deactivate or quit:

1. Kills `caffeinate`
2. **`sudo pmset -a disablesleep 0`** — restores normal sleep behavior

The `setup-sudoers.sh` script adds a NOPASSWD rule for `pmset` only, so the toggle is instant and doesn't prompt for your password.

## Use cases

- Let **Claude Code / Cursor / Codex** finish a long task while your Mac is in your bag
- Keep **SSH sessions** alive on the go with mobile hotspot
- Run **long builds or deployments** without babysitting the lid
- Keep a **dev server** running while you step away

## Requirements

- macOS 13+ (Ventura or later)
- Apple Silicon or Intel

## License

MIT
