#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> RTK feature: version=${VERSION}"

# Ensure curl and tar are available (minimal images may not have them)
if ! command -v curl &>/dev/null || ! command -v tar &>/dev/null; then
    echo "==> Installing missing dependencies..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates tar
fi

# Detect architecture — build candidate target triples to try.
# v0.23.0+ ships musl for x86_64; older releases use gnu.
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  TARGETS=("x86_64-unknown-linux-musl" "x86_64-unknown-linux-gnu") ;;
    aarch64|arm64)  TARGETS=("aarch64-unknown-linux-gnu") ;;
    *)
        echo "ERROR: unsupported architecture: $ARCH"
        exit 1
        ;;
esac
echo "==> Detected architecture: ${ARCH}"

# Resolve version
if [ "$VERSION" = "latest" ]; then
    VERSION=$(curl -fsSL "https://api.github.com/repos/rtk-ai/rtk/releases/latest" \
        | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        echo "ERROR: failed to resolve latest RTK version from GitHub API"
        exit 1
    fi
    echo "==> Resolved latest version: ${VERSION}"
fi

# Ensure version has 'v' prefix (GitHub tags use v0.23.0 format)
case "$VERSION" in
    v*) ;;
    *)  VERSION="v${VERSION}" ;;
esac

# Download and install — try each target triple until one succeeds
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

DOWNLOADED=false
for TARGET in "${TARGETS[@]}"; do
    TARBALL="rtk-${TARGET}.tar.gz"
    DOWNLOAD_URL="https://github.com/rtk-ai/rtk/releases/download/${VERSION}/${TARBALL}"
    echo "==> Trying ${DOWNLOAD_URL}..."
    if curl -fsSL "$DOWNLOAD_URL" -o "${TMP_DIR}/${TARBALL}" 2>/dev/null; then
        DOWNLOADED=true
        break
    fi
done

if [ "$DOWNLOADED" = false ]; then
    echo "ERROR: no compatible RTK binary found for ${ARCH} in release ${VERSION}"
    exit 1
fi

tar -xzf "${TMP_DIR}/${TARBALL}" -C "$TMP_DIR"

# The tarball contains a single 'rtk' binary at the root
if [ ! -f "${TMP_DIR}/rtk" ]; then
    echo "ERROR: rtk binary not found in archive"
    exit 1
fi
install -m 0755 "${TMP_DIR}/rtk" /usr/local/bin/rtk

echo "==> RTK $(rtk --version) installed at $(command -v rtk)"

# Initialize RTK global configuration
echo "==> Running rtk init --global..."
if [ -n "${_REMOTE_USER:-}" ] && [ "$_REMOTE_USER" != "root" ]; then
    su - "$_REMOTE_USER" -c "rtk init --global"
else
    rtk init --global
fi

echo "==> RTK feature install complete"
