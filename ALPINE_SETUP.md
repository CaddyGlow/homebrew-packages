# Alpine Linux Package Setup Guide

This guide explains how to set up a custom Alpine Linux repository for CaddyGlow packages.

## For Package Maintainers: Creating a Custom Alpine Repository

### 1. Build All Packages

```bash
# Install build dependencies
apk add alpine-sdk

# Generate signing key (first time only)
abuild-keygen -a -i

# Build each package
cd alpine/
for apkbuild in APKBUILD.*; do
    tool=$(echo $apkbuild | sed 's/APKBUILD.//')
    cp $apkbuild APKBUILD
    abuild -r
    rm APKBUILD
done
```

### 2. Create Repository Index

```bash
# Create repository directory structure
mkdir -p ~/alpine-repo/x86_64
mkdir -p ~/alpine-repo/aarch64

# Copy built packages
cp ~/packages/*/x86_64/*.apk ~/alpine-repo/x86_64/
cp ~/packages/*/aarch64/*.apk ~/alpine-repo/aarch64/

# Generate repository index
cd ~/alpine-repo/x86_64
apk index -o APKINDEX.tar.gz *.apk
abuild-sign -k ~/.abuild/*-*.rsa APKINDEX.tar.gz

cd ~/alpine-repo/aarch64
apk index -o APKINDEX.tar.gz *.apk
abuild-sign -k ~/.abuild/*-*.rsa APKINDEX.tar.gz
```

### 3. Host the Repository

You can host the repository on GitHub Pages, a web server, or any static hosting:

```bash
# Example: GitHub Pages
git clone https://github.com/CaddyGlow/alpine-repo.git
cp -r ~/alpine-repo/* alpine-repo/
cd alpine-repo/
git add .
git commit -m "Update Alpine packages"
git push
```

### 4. Publish Public Key

Users need your public signing key. Put it in the repository:

```bash
cp ~/.abuild/*.rsa.pub alpine-repo/caddyglow.rsa.pub
```

## For End Users: Installing Packages

### Method 1: Download Pre-built Packages (Easiest) ⭐

Pre-built Alpine packages are available as GitHub release assets:

```bash
# Find latest Alpine packages release
# Visit: https://github.com/CaddyGlow/homebrew-packages/releases

# Download package for your architecture
wget https://github.com/CaddyGlow/homebrew-packages/releases/download/alpine-packages-v20251026/quickctx-0.1.4-r0.apk

# Install (as root)
apk add --allow-untrusted quickctx-0.1.4-r0.apk

# Verify installation
quickctx --version
```

**Available architectures:**
- x86_64
- aarch64

### Method 2: Build from APKBUILD

If you prefer to build packages yourself:

```bash
# Install build tools
apk add alpine-sdk

# Clone package repository
git clone https://github.com/CaddyGlow/homebrew-packages.git
cd homebrew-packages/alpine

# Build a specific package
abuild-keygen -a -i  # First time only
cp APKBUILD.quickctx APKBUILD
abuild -r

# Install (allow untrusted since it's self-built)
apk add --allow-untrusted ~/packages/*/$(uname -m)/quickctx-*.apk
```

## Manual Installation (Without Repository)

If you don't want to set up a repository, you can build and install manually:

```bash
# Install build tools
apk add alpine-sdk git

# Clone package repository
git clone https://github.com/CaddyGlow/homebrew-packages.git
cd homebrew-packages/alpine

# Build a specific package
abuild-keygen -a -i  # First time only
cp APKBUILD.quickctx APKBUILD
abuild -r

# Install (allow untrusted since it's self-built)
apk add --allow-untrusted ~/packages/*/$(uname -m)/quickctx-*.apk
```

## Updating Packages

When new versions are released:

### With Repository
```bash
apk update
apk upgrade quickctx shelltape ghdl
```

### Manual
```bash
cd homebrew-packages
git pull
cd alpine
cp APKBUILD.quickctx APKBUILD
abuild -r
apk add --allow-untrusted ~/packages/*/$(uname -m)/quickctx-*.apk
```

## Troubleshooting

### "untrusted signature" error
```bash
# Make sure the public key is installed
ls /etc/apk/keys/caddyglow.rsa.pub

# Or use --allow-untrusted flag for local builds
apk add --allow-untrusted package.apk
```

### Architecture mismatch
```bash
# Check your architecture
uname -m

# Make sure you're installing the correct architecture package
# x86_64 or aarch64
```

## Automation

You can automate repository updates with GitHub Actions when new releases are published:

1. Build packages in CI
2. Sign packages with stored key
3. Upload to GitHub Pages or release assets
4. Users get updates automatically via `apk update`
