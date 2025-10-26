#!/data/data/com.termux/files/usr/bin/bash
# CaddyGlow Termux Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- <tool> [version]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

die() {
    error "$*"
    exit 1
}

# Parse arguments
TOOL=$1
VERSION=$2

if [ -z "$TOOL" ]; then
    echo "CaddyGlow Termux Installer"
    echo ""
    echo "Usage: $0 <tool> [version]"
    echo ""
    echo "Available tools:"
    echo "  quickctx   - Quick context switching"
    echo "  shelltape  - Shell session recording"
    echo "  ghdl       - GitHub download helper"
    echo ""
    echo "Examples:"
    echo "  $0 quickctx         # Install latest version"
    echo "  $0 quickctx 0.1.4   # Install specific version"
    echo ""
    echo "Quick install (one-liner):"
    echo "  curl -fsSL https://raw.githubusercontent.com/CaddyGlow/homebrew-packages/main/install-termux.sh | bash -s -- quickctx"
    exit 1
fi

# Tool repository mapping
case "$TOOL" in
    quickctx|shelltape|ghdl)
        REPO="CaddyGlow/$TOOL"
        ;;
    *)
        die "Unknown tool: $TOOL"
        ;;
esac

# Detect latest version if not specified
if [ -z "$VERSION" ]; then
    info "Fetching latest version..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        die "Could not detect latest version. Please specify version manually."
    fi
    info "Latest version: $VERSION"
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

# Construct download URL
URL="https://github.com/$REPO/releases/download/v$VERSION/$TOOL-aarch64-linux-android.tar.gz"

info "Installing $TOOL v$VERSION..."

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    die "Unsupported architecture: $ARCH (only aarch64 is supported)"
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# Download
info "Downloading from $URL..."
if ! wget -q --show-progress -O "$TMP_DIR/$TOOL.tar.gz" "$URL"; then
    die "Failed to download $TOOL v$VERSION. Please check if this version exists."
fi

# Extract
info "Extracting..."
tar -xzf "$TMP_DIR/$TOOL.tar.gz" -C "$TMP_DIR/"

# Find all binaries in the archive
BINARIES=$(tar -tzf "$TMP_DIR/$TOOL.tar.gz" | grep -E '^[^/]+$' | grep -v '/$')

if [ -z "$BINARIES" ]; then
    die "No binaries found in archive"
fi

# Install binaries
for binary in $BINARIES; do
    if [ -f "$TMP_DIR/$binary" ]; then
        info "Installing $binary..."
        chmod +x "$TMP_DIR/$binary"
        mv "$TMP_DIR/$binary" "$PREFIX/bin/"
        success "$binary installed to $PREFIX/bin/$binary"
    fi
done

# Verify installation
if command -v "$TOOL" >/dev/null 2>&1; then
    echo ""
    success "$TOOL v$VERSION installed successfully!"
    echo ""
    info "Verify installation:"
    echo "  $TOOL --version"
    echo ""

    # Show version if binary supports it
    if $TOOL --version 2>/dev/null; then
        :
    fi
else
    error "Installation completed but $TOOL command not found in PATH"
    error "Please ensure $PREFIX/bin is in your PATH"
fi
