#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> AWF CLI feature: version=${VERSION}"

# Ensure curl, sha256sum, and ca-certificates are available
if ! command -v curl &>/dev/null || ! command -v sha256sum &>/dev/null; then
    echo "==> Installing missing dependencies..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates coreutils
    apt-get clean && rm -rf /var/lib/apt/lists/*
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)   ARCH_SUFFIX="amd64" ;;
    aarch64|arm64)   ARCH_SUFFIX="arm64" ;;
    *)
        echo "ERROR: unsupported architecture: $ARCH"
        exit 1
        ;;
esac
echo "==> Detected architecture: ${ARCH} (${ARCH_SUFFIX})"

# Resolve version
if [ "$VERSION" = "latest" ]; then
    VERSION=$(curl -fsSL "https://api.github.com/repos/awf-project/cli/releases/latest" \
        | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        echo "ERROR: failed to resolve latest AWF CLI version from GitHub API"
        exit 1
    fi
    echo "==> Resolved latest version: ${VERSION}"
fi

# Ensure version has 'v' prefix (GitHub tags use v0.9.0 format)
case "$VERSION" in
    v*) ;;
    *)  VERSION="v${VERSION}" ;;
esac

# Download tarball and checksums
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

ARTIFACT="awf_linux_${ARCH_SUFFIX}.tar.gz"
DOWNLOAD_URL="https://github.com/awf-project/cli/releases/download/${VERSION}/${ARTIFACT}"
CHECKSUMS_URL="https://github.com/awf-project/cli/releases/download/${VERSION}/checksums.txt"

echo "==> Downloading ${DOWNLOAD_URL}..."
curl -fsSL "$DOWNLOAD_URL" -o "${TMP_DIR}/${ARTIFACT}"

echo "==> Downloading checksums.txt..."
curl -fsSL "$CHECKSUMS_URL" -o "${TMP_DIR}/checksums.txt"

# Verify SHA256 checksum
echo "==> Verifying checksum..."
EXPECTED_SUM=$(grep "  ${ARTIFACT}$" "${TMP_DIR}/checksums.txt" | awk '{print $1}')
if [ -z "$EXPECTED_SUM" ]; then
    echo "ERROR: artifact ${ARTIFACT} not found in checksums.txt"
    exit 1
fi

ACTUAL_SUM=$(sha256sum "${TMP_DIR}/${ARTIFACT}" | awk '{print $1}')
if [ "$EXPECTED_SUM" != "$ACTUAL_SUM" ]; then
    echo "ERROR: SHA256 checksum mismatch"
    echo "  expected: ${EXPECTED_SUM}"
    echo "  actual:   ${ACTUAL_SUM}"
    exit 1
fi
echo "==> Checksum verified"

# Extract and install binary
tar -xzf "${TMP_DIR}/${ARTIFACT}" -C "$TMP_DIR"

if [ ! -f "${TMP_DIR}/awf" ]; then
    echo "ERROR: awf binary not found in archive"
    exit 1
fi

install -m 0755 "${TMP_DIR}/awf" /usr/local/bin/awf

echo "==> AWF CLI $(awf version 2>&1 | head -1) installed at $(command -v awf)"
echo "==> AWF CLI feature install complete"
