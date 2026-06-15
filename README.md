# API Matrix — macOS

A native macOS menu bar app for managing API keys. Companion to the [API Matrix](https://github.com/HiNesslio/apikey-vault) iOS app.

**Clean white UI · Native Keychain sync · Menu bar quick access**

## Features

- **Menu Bar Quick Access** — View and copy API keys from the status bar
- **Full Window Management** — Sidebar + detail view for key management
- **iCloud Keychain Sync** — Automatically syncs with the iOS app via shared Keychain
- **Secure** — Keys stored in macOS Keychain, never on disk
- **Search** — Instant search across all keys
- **Copy & Export** — Copy keys, generate curl commands, .env snippets, JSON export
- **Privacy** — Keys masked by default, auto-hide after 10 seconds, auto-lock option

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.4+ (to build from source)

## Installation

### Download (Pre-built)

```bash
curl -L https://github.com/HiNesslio/api-matrix-mac/releases/latest/download/API-Matrix.zip -o API-Matrix.zip
unzip API-Matrix.zip
open API\ Matrix.app
```

> **Note:** Pre-built releases are ad-hoc signed. If Gatekeeper blocks opening, right-click the app and select **Open**.

### Build from Source

```bash
git clone https://github.com/HiNesslio/api-matrix-mac.git
cd api-matrix-mac
make build
make app-bundle
open Build/API\ Matrix.app
```

## Usage

1. Launch the app — the key icon appears in your menu bar
2. Click the icon to see your API keys (synced from iOS app via Keychain)
3. Click **Copy** to copy a key, **Add Key** to create a new one
4. Click **Open Full App** for the full management window

## Sync with iOS

Keys are stored in a shared Keychain access group. If you have the iOS app installed on the same Apple ID, keys sync automatically.

## License

MIT
