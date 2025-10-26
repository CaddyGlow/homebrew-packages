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

### Option 4: Install Pre-built Binaries (Easiest)

Since the packages just download pre-built binaries, users can install directly:

```bash
# Create installation directory if needed
mkdir -p ~/.local/bin

# Download and extract (example: quickctx v0.1.4)
wget https://github.com/CaddyGlow/quickctx/releases/download/v0.1.4/quickctx-aarch64-linux-android.tar.gz
tar -xzf quickctx-aarch64-linux-android.tar.gz
chmod +x quickctx quickctx-analyze
mv quickctx quickctx-analyze ~/.local/bin/

# Add to PATH if not already
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
quickctx --version
```

### Quick Install Script

Create a simple install script for users:

```bash
#!/data/data/com.termux/files/usr/bin/bash
# install-caddyglow.sh

TOOL=$1
VERSION=$2

if [ -z "$TOOL" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <tool> <version>"
    echo "Example: $0 quickctx 0.1.4"
    exit 1
fi

REPO="CaddyGlow/$TOOL"
URL="https://github.com/$REPO/releases/download/v$VERSION/$TOOL-aarch64-linux-android.tar.gz"

echo "Installing $TOOL v$VERSION..."
wget -O /tmp/$TOOL.tar.gz "$URL"
tar -xzf /tmp/$TOOL.tar.gz -C /tmp/
chmod +x /tmp/$TOOL
mv /tmp/$TOOL $PREFIX/bin/
rm /tmp/$TOOL.tar.gz

echo "✓ $TOOL installed successfully!"
$TOOL --version
```

Usage:
```bash
# Make script executable
chmod +x install-caddyglow.sh

# Install any tool
./install-caddyglow.sh quickctx 0.1.4
./install-caddyglow.sh shelltape 0.1.4
./install-caddyglow.sh ghdl 0.1.3
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
