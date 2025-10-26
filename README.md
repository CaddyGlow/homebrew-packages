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

```bash
# Alpine packages are available via APKBUILD files in the alpine/ directory
# To use them, you'll need to build the package using Alpine's build system

# Example for building a package:
cd alpine/
abuild -r APKBUILD.<tool-name>
```

## Termux (Android)

```bash
# Termux packages are available via build.sh files in the termux/ directory
# These packages can be built using the termux-packages build system

# For more information on building Termux packages, visit:
# https://github.com/termux/termux-packages
```

## Repository Structure

```
homebrew-packages/
├── Formula/           # Homebrew formulas (macOS/Linux)
├── scoop/            # Scoop manifests (Windows)
├── alpine/           # Alpine Linux APKBUILD files
└── termux/           # Termux build scripts
```

## Available Tools

Tools will be listed here as they are added to this repository.

## Links

- [CaddyGlow GitHub](https://github.com/CaddyGlow)
- [Report Issues](https://github.com/CaddyGlow/homebrew-packages/issues)
