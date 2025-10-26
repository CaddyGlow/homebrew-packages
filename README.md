# CaddyGlow Packages

Official package repository for CaddyGlow tools. Install via Homebrew or Scoop.

## Homebrew (macOS/Linux)

```bash
# Add the tap
brew tap CaddyGlow/packages

# Install any tool
brew install <tool-name>

# Update
brew update && brew upgrade <tool-name>
```

## Scoop (Windows)

```powershell
# Add the bucket
scoop bucket add caddyglow https://github.com/CaddyGlow/homebrew-packages

# Install any tool
scoop install <tool-name>

# Update
scoop update && scoop update <tool-name>
```

## Alpine Linux

Alpine packages can be installed by building from APKBUILD files or using a custom repository:

```bash
# Quick install (manual build)
apk add alpine-sdk
git clone https://github.com/CaddyGlow/homebrew-packages.git
cd homebrew-packages/alpine
cp APKBUILD.quickctx APKBUILD
abuild-keygen -a -i  # First time only
abuild -r
apk add --allow-untrusted ~/packages/*/$(uname -m)/quickctx-*.apk
```

📖 **[Complete Alpine Setup Guide](ALPINE_SETUP.md)** - Includes custom repository setup

## Termux (Android)

One-command installation for Termux:

```bash
# Install any tool (auto-detects latest version)
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx

# Or install specific version
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx 0.1.4
```

📖 **[Complete Termux Setup Guide](TERMUX_SETUP.md)** - Includes all installation methods

## Repository Structure

```
homebrew-packages/
├── Formula/           # Homebrew formulas (macOS/Linux)
├── scoop/            # Scoop manifests (Windows)
├── alpine/           # Alpine Linux APKBUILD files
└── termux/           # Termux build scripts
```

## Available Tools

| Tool | Version | Platforms |
|------|---------|-----------|
| [quickctx](https://github.com/CaddyGlow/quickctx) | 0.1.4 | macOS, Linux, Windows, Alpine, Termux |
| [shelltape](https://github.com/CaddyGlow/shelltape) | 0.1.4 | macOS, Linux, Windows, Alpine, Termux |
| [ghdl](https://github.com/CaddyGlow/ghdl) | 0.1.3 | macOS, Linux, Windows, Alpine, Termux |

## Installation Methods Quick Reference

| Platform | Package Manager | Command |
|----------|----------------|---------|
| macOS/Linux | Homebrew | `brew install CaddyGlow/packages/<tool>` |
| Windows | Scoop | `scoop install <tool>` |
| Alpine Linux | apk (manual) | `abuild -r APKBUILD.<tool>` |
| Alpine Linux | apk (repo) | `apk add <tool>` (after repo setup) |
| Termux | Direct binary | `wget + tar + mv` (see guide) |
| Termux | pkg (future) | `pkg install <tool>` (when in official repo) |

See the detailed guides above for complete installation instructions.

## Links

- [CaddyGlow GitHub](https://github.com/CaddyGlow)
- [Report Issues](https://github.com/CaddyGlow/homebrew-packages/issues)
