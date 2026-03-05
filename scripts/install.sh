#!/bin/sh
# init-agent installation script
# Usage: curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh
# Usage with version: curl -sSL ... | sh -s -- v1.0.0

set -e

# Configuration
REPO="leebase/init-agent"
BINARY_NAME="init-agent"

# Parse arguments
VERSION="latest"
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            echo "init-agent installation script"
            echo ""
            echo "Usage:"
            echo "  curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh"
            echo "  curl -sSL ... | sh -s -- [VERSION]"
            echo ""
            echo "Arguments:"
            echo "  VERSION    Specific version to install (e.g., v1.0.0 or 1.0.0)"
            echo "             Default: latest"
            echo ""
            echo "Environment Variables:"
            echo "  NO_COLOR   Set to disable colored output"
            echo ""
            echo "Examples:"
            echo "  # Install latest version"
            echo "  curl -sSL https://raw.githubusercontent.com/leebase/init-agent/main/scripts/install.sh | sh"
            echo ""
            echo "  # Install specific version"
            echo "  curl -sSL ... | sh -s -- v1.0.0"
            echo ""
            echo "  # Install without colors"
            echo "  NO_COLOR=1 curl -sSL ... | sh"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "Run with --help for usage information" >&2
            exit 1
            ;;
        *)
            VERSION="$1"
            ;;
    esac
    shift
done

# Colors (disabled if NO_COLOR is set or not a TTY)
RED=''
GREEN=''
YELLOW=''
CYAN=''
BOLD=''
RESET=''

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    RED='\033[31m'
    GREEN='\033[32m'
    YELLOW='\033[33m'
    CYAN='\033[36m'
    BOLD='\033[1m'
    RESET='\033[0m'
fi

# Print functions
info() {
    printf "${CYAN}ℹ${RESET}  %s\n" "$1"
}

success() {
    printf "${GREEN}✓${RESET}  %s\n" "$1"
}

warn() {
    printf "${YELLOW}⚠${RESET}  %s\n" "$1"
}

error() {
    printf "${RED}✗${RESET}  %s\n" "$1" >&2
}

# Detect platform
 detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$OS" in
        linux)
            PLATFORM="linux"
            ;;
        darwin)
            PLATFORM="macos"
            ;;
        msys*|mingw*|cygwin*)
            PLATFORM="windows"
            ;;
        *)
            if [ "$OS" = "windows_nt" ]; then
                PLATFORM="windows"
            else
                error "Unsupported operating system: $OS"
                exit 1
            fi
            ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64)
            ARCH_TARGET="x86_64"
            ;;
        arm64|aarch64)
            ARCH_TARGET="aarch64"
            ;;
        i386|i686)
            if [ "$PLATFORM" = "windows" ]; then
                error "32-bit Windows is not supported. Please use 64-bit Windows."
                exit 1
            fi
            error "Unsupported architecture: $ARCH"
            exit 1
            ;;
        *)
            error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    
    # macOS ARM64 can run x86_64 binaries via Rosetta 2
    if [ "$PLATFORM" = "macos" ] && [ "$ARCH_TARGET" = "aarch64" ]; then
        HAS_ROSETTA=$(/usr/bin/pgrep oahd >/dev/null 2>&1 && echo "yes" || echo "no")
        if [ "$HAS_ROSETTA" = "no" ]; then
            info "Note: Rosetta 2 may be needed for some operations"
        fi
    fi
}

# Check for required commands
check_dependencies() {
    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required but not installed."
        if [ "$PLATFORM" = "macos" ]; then
            info "Install with: brew install curl"
        elif [ "$PLATFORM" = "linux" ]; then
            info "Install with: apt-get install curl  or  yum install curl"
        fi
        exit 1
    fi
    
    if ! command -v tar >/dev/null 2>&1 && [ "$PLATFORM" != "windows" ]; then
        error "tar is required but not installed."
        exit 1
    fi
}

# Determine installation directory
get_install_dir() {
    # Try /usr/local/bin first (system-wide)
    if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
        INSTALL_DIR="/usr/local/bin"
        return
    fi
    
    # Check if we can write to /usr/local/bin with sudo
    if [ -d "/usr/local/bin" ]; then
        warn "/usr/local/bin exists but is not writable by current user."
        info "Installation will use sudo for system-wide installation."
        USE_SUDO="yes"
        INSTALL_DIR="/usr/local/bin"
        return
    fi
    
    # Fall back to ~/.local/bin (user-local)
    LOCAL_BIN="$HOME/.local/bin"
    if [ -d "$LOCAL_BIN" ] || mkdir -p "$LOCAL_BIN" 2>/dev/null; then
        INSTALL_DIR="$LOCAL_BIN"
        warn "Installing to $INSTALL_DIR (not in PATH? Add: export PATH=\"\$HOME/.local/bin:\$PATH\")"
        return
    fi
    
    # Last resort: ~/bin
    USER_BIN="$HOME/bin"
    if mkdir -p "$USER_BIN" 2>/dev/null; then
        INSTALL_DIR="$USER_BIN"
        warn "Installing to $INSTALL_DIR (not in PATH? Add: export PATH=\"\$HOME/bin:\$PATH\")"
        return
    fi
    
    error "Could not find a suitable installation directory."
    info "Please create ~/.local/bin or ~/bin and ensure it's in your PATH."
    exit 1
}

# Download binary
download_binary() {
    TARGET="${ARCH_TARGET}-${PLATFORM}"
    
    # Handle Windows specially
    if [ "$PLATFORM" = "windows" ]; then
        error "Windows installation via this script is not supported."
        info "Please download the Windows binary manually from:"
        info "  https://github.com/${REPO}/releases/${VERSION}"
        info ""
        info "Download: init-agent-x86_64-windows.zip"
        info "Extract and add to your PATH manually."
        exit 1
    fi
    
    # Construct download URL
    if [ "$VERSION" = "latest" ]; then
        DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/init-agent-${TARGET}.tar.gz"
    else
        # Ensure version starts with 'v'
        case "$VERSION" in
            v*) ;;  # Already has v prefix
            *) VERSION="v${VERSION}" ;;
        esac
        DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/init-agent-${TARGET}.tar.gz"
    fi
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    
    info "Downloading init-agent ${VERSION} for ${TARGET}..."
    info "URL: $DOWNLOAD_URL"
    
    # Download with curl
    HTTP_CODE=$(curl -sSL -w "%{http_code}" -o "$TEMP_DIR/init-agent.tar.gz" "$DOWNLOAD_URL" 2>&1 || echo "000")
    
    if [ "$HTTP_CODE" != "200" ]; then
        error "Download failed (HTTP $HTTP_CODE)"
        info "The release may not exist for this platform: ${TARGET}"
        info "Available releases: https://github.com/${REPO}/releases"
        
        # Show specific error for common cases
        if [ "$HTTP_CODE" = "404" ]; then
            info ""
            info "Possible causes:"
            info "  - The version '${VERSION}' does not exist"
            info "  - This platform (${TARGET}) is not supported"
            info "  - The release is still being built"
        fi
        exit 1
    fi
    
    success "Downloaded successfully"
    
    # Extract
    info "Extracting archive..."
    if ! tar -xzf "$TEMP_DIR/init-agent.tar.gz" -C "$TEMP_DIR" 2>/dev/null; then
        error "Failed to extract archive"
        exit 1
    fi
    
    # Find extracted binary
    EXTRACTED_BINARY=$(find "$TEMP_DIR" -name "init-agent" -type f | head -n1)
    if [ -z "$EXTRACTED_BINARY" ]; then
        error "Could not find init-agent binary in archive"
        exit 1
    fi
    
    success "Extracted successfully"
}

# Install binary
install_binary() {
    info "Installing to ${INSTALL_DIR}/${BINARY_NAME}..."
    
    # Check if binary already exists
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        warn "Binary already exists at ${INSTALL_DIR}/${BINARY_NAME}"
        
        # Get version of existing binary if possible
        EXISTING_VERSION=$(${INSTALL_DIR}/${BINARY_NAME} --version 2>/dev/null || echo "unknown")
        info "Existing version: ${EXISTING_VERSION}"
        
        # Backup existing binary
        BACKUP_PATH="${INSTALL_DIR}/${BINARY_NAME}.backup.$(date +%s)"
        if [ -z "$USE_SUDO" ]; then
            cp "${INSTALL_DIR}/${BINARY_NAME}" "$BACKUP_PATH" 2>/dev/null || true
        else
            sudo cp "${INSTALL_DIR}/${BINARY_NAME}" "$BACKUP_PATH" 2>/dev/null || true
        fi
        info "Existing binary backed up to: $BACKUP_PATH"
    fi
    
    # Install with or without sudo
    if [ -z "$USE_SUDO" ]; then
        cp "$EXTRACTED_BINARY" "${INSTALL_DIR}/${BINARY_NAME}"
        chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
    else
        sudo cp "$EXTRACTED_BINARY" "${INSTALL_DIR}/${BINARY_NAME}"
        sudo chmod +x "${INSTALL_DIR}/${BINARY_NAME}"
    fi
    
    success "Installed successfully"
}

# Verify installation
verify_installation() {
    info "Verifying installation..."
    
    if [ ! -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        error "Installation verification failed: binary not found"
        exit 1
    fi
    
    # Check if binary is executable
    if [ ! -x "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        error "Installation verification failed: binary is not executable"
        exit 1
    fi
    
    # Try to run the binary to get version
    INSTALLED_VERSION=$(${INSTALL_DIR}/${BINARY_NAME} --version 2>/dev/null || echo "unknown")
    
    if [ "$INSTALLED_VERSION" = "unknown" ]; then
        warn "Could not verify binary version, but installation completed"
    else
        success "Installation verified: ${INSTALLED_VERSION}"
    fi
    
    # Check if install dir is in PATH
    if [ -n "${PATH##*${INSTALL_DIR}*}" ]; then
        warn "${INSTALL_DIR} is not in your PATH"
        info "Add the following to your shell configuration:"
        info "  export PATH=\"${INSTALL_DIR}:\$PATH\""
    fi
}

# Print post-install instructions
print_completion() {
    echo ""
    printf "${BOLD}${GREEN}Installation complete!${RESET}\n"
    echo ""
    echo "init-agent has been installed to: ${INSTALL_DIR}/${BINARY_NAME}"
    echo ""
    echo "Get started:"
    echo "  init-agent --help              # Show help"
    echo "  init-agent --list              # List available profiles"
    echo "  init-agent my-project          # Create a new project"
    echo "  init-agent my-cli --profile zig-cli"
    echo ""
    echo "Documentation: https://github.com/${REPO}"
    echo ""
}

# Main
main() {
    printf "${BOLD}init-agent Installer${RESET}\n"
    echo "===================="
    echo ""
    
    detect_platform
    check_dependencies
    get_install_dir
    download_binary
    install_binary
    verify_installation
    print_completion
}

# Run main function
main
