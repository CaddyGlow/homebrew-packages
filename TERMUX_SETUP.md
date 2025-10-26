# Termux Package Setup Guide

This guide explains how to build and distribute CaddyGlow packages for Termux (Android).

## For Package Maintainers: Building Termux Packages

### Option 1: Using Termux Build System (Recommended)

Termux has an official build system for creating packages. To submit packages to the official Termux repository:

1. Fork the [termux-packages](https://github.com/termux/termux-packages) repository
2. Add your package build scripts
3. Submit a pull request

```bash
# Clone termux-packages
git clone https://github.com/termux/termux-packages
cd termux-packages

# Create package directory for each tool
mkdir -p packages/quickctx
mkdir -p packages/shelltape
mkdir -p packages/ghdl

# Copy build.sh files (rename from build.sh.toolname to build.sh)
cp /path/to/homebrew-packages/termux/build.sh.quickctx packages/quickctx/build.sh
cp /path/to/homebrew-packages/termux/build.sh.shelltape packages/shelltape/build.sh
cp /path/to/homebrew-packages/termux/build.sh.ghdl packages/ghdl/build.sh

# Build packages
./build-package.sh quickctx
./build-package.sh shelltape
./build-package.sh ghdl
```

### Option 2: Custom Termux Repository

You can create a custom repository for quick distribution:

```bash
# On a Linux system with Termux build environment
# Build packages
./build-package.sh -a aarch64 quickctx
./build-package.sh -a aarch64 shelltape
./build-package.sh -a aarch64 ghdl

# Create repository structure
mkdir -p termux-repo/dists/stable/main/binary-aarch64
cp output/*.deb termux-repo/dists/stable/main/binary-aarch64/

# Generate Packages index
cd termux-repo/dists/stable/main/binary-aarch64
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz

# Host on GitHub Pages or web server
```

### Option 3: Direct .deb Installation

Build and distribute .deb files directly:

```bash
# After building with termux-packages
# Upload .deb files to GitHub Releases
gh release upload v0.1.4 quickctx_0.1.4_aarch64.deb
```

## For End Users: Installing Packages

### Option 1: From Official Termux Repository (Future)

Once packages are accepted into official Termux repos:

```bash
# Update package list
pkg update

# Install packages
pkg install quickctx
pkg install shelltape
pkg install ghdl
```

### Option 2: From Custom Repository

If using a custom repository:

```bash
# Add custom repository
echo "deb https://caddyglow.github.io/termux-repo stable main" \
  > $PREFIX/etc/apt/sources.list.d/caddyglow.list

# Update and install
pkg update
pkg install quickctx shelltape ghdl
```

### Option 3: Direct .deb Installation

Download and install .deb files directly:

```bash
# Download from GitHub releases
wget https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx_0.1.4_aarch64.deb

# Install
pkg install ./quickctx_0.1.4_aarch64.deb
```

### Option 4: Automated Install Script (Easiest) ⭐

Use the official CaddyGlow installer for one-command installation:

```bash
# One-liner install (latest version)
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx

# Install specific version
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx 0.1.4

# Install all tools
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- shelltape
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- ghdl
```

The installer automatically:
- Detects the latest version (or uses specified version)
- Downloads and verifies the binary
- Extracts and installs to `$PREFIX/bin`
- Makes binaries executable
- Verifies installation

### Option 5: Install Pre-built Binaries Manually

If you prefer manual installation:

```bash
# Download and extract (example: quickctx v0.1.4)
wget https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-aarch64-linux-android.tar.gz
tar -xzf quickctx-aarch64-linux-android.tar.gz
chmod +x quickctx quickctx-analyze
mv quickctx quickctx-analyze $PREFIX/bin/

# Verify installation
quickctx --version
```

### Discover Available Tools

View all available tools and versions:

```bash
# Download manifest
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/termux-manifest.json

# Pretty print with jq
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/termux-manifest.json | jq .

# List just tool names and versions
curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/termux-manifest.json | \
  jq -r '.tools | to_entries[] | "\(.key): \(.value.version)"'
```

## Verifying Installation

```bash
# Check if tools are in PATH
which quickctx
which shelltape
which ghdl

# Test each tool
quickctx --version
shelltape --version
ghdl --version
```

## Updating Packages

### From Repository
```bash
pkg update
pkg upgrade quickctx shelltape ghdl
```

### Manual Update
```bash
# Download new version
wget https://github.com/CaddyGlow/quickctx/releases/download/v0.2.0/quickctx-aarch64-linux-android.tar.gz

# Extract and replace
tar -xzf quickctx-aarch64-linux-android.tar.gz
chmod +x quickctx
mv quickctx $PREFIX/bin/
```

## Uninstalling

### If installed via pkg
```bash
pkg uninstall quickctx
```

### If installed manually
```bash
rm $PREFIX/bin/quickctx
# Or if installed to ~/.local/bin
rm ~/.local/bin/quickctx
```

## Troubleshooting

### Permission denied
```bash
# Make sure binary is executable
chmod +x $PREFIX/bin/quickctx
```

### Command not found
```bash
# Check if $PREFIX/bin is in PATH
echo $PATH

# Add to PATH if needed
export PATH="$PREFIX/bin:$PATH"
```

### Architecture mismatch
```bash
# Verify your device architecture
uname -m

# Should be aarch64 for modern Android devices
# If armv7l, you need the armv7 build
```

## Contributing to Official Termux Repository

To get packages into official Termux repository:

1. Read [Termux packaging guidelines](https://github.com/termux/termux-packages/blob/master/CONTRIBUTING.md)
2. Create proper build.sh following their format
3. Test thoroughly on Termux
4. Submit PR to termux/termux-packages
5. Address review feedback

## Notes

- Termux packages use pre-built Android binaries from GitHub releases
- No compilation happens on the device (just download and install)
- All CaddyGlow tools require aarch64 (ARM64) Android devices
- Minimum Android version depends on your Rust build target
