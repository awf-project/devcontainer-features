#!/bin/bash
set -e

# AWF CLI devcontainer feature
#
# Since awf-project/cli is a private repo, downloading the binary requires
# GitHub authentication. The gh CLI config is mounted from the host at runtime,
# so the actual download happens via postCreateCommand, not at build time.
#
# This script installs the download helper that runs at container start.

echo "==> AWF CLI feature: setting up deferred install"

# Ensure curl and tar are available (needed by the download script)
if ! command -v curl &>/dev/null || ! command -v tar &>/dev/null; then
    echo "==> Installing missing dependencies..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates tar
fi

# Install the download helper script
cat > /usr/local/bin/awf-install << 'SCRIPT'
#!/bin/bash
set -e

# Skip if already installed
if command -v awf &>/dev/null; then
    echo "==> AWF CLI already installed: $(awf --version 2>&1)"
    exit 0
fi

echo "==> AWF CLI: downloading latest version..."

# Require gh CLI authenticated
if ! command -v gh &>/dev/null; then
    echo "ERROR: gh CLI is required to download AWF CLI from the private repository"
    echo "Add ghcr.io/devcontainers/features/github-cli feature to your devcontainer.json"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "ERROR: gh CLI is not authenticated"
    echo "Mount your host gh config: \"source=\${localEnv:HOME}/.config/gh,target=/home/\${remoteUser}/.config/gh,type=bind,readonly\""
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)   GO_ARCH="amd64" ;;
    aarch64|arm64)   GO_ARCH="arm64" ;;
    *)
        echo "ERROR: unsupported architecture: $ARCH"
        exit 1
        ;;
esac

REPO="awf-project/cli"
TARBALL="awf_linux_${GO_ARCH}.tar.gz"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download latest release asset using gh CLI (handles private repo auth)
echo "==> Downloading ${TARBALL} from ${REPO}..."
gh release download --repo "$REPO" --pattern "$TARBALL" --dir "$TMP_DIR"

tar -xzf "${TMP_DIR}/${TARBALL}" -C "$TMP_DIR"

if [ ! -f "${TMP_DIR}/awf" ]; then
    echo "ERROR: awf binary not found in archive"
    exit 1
fi

sudo install -m 0755 "${TMP_DIR}/awf" /usr/local/bin/awf

echo "==> AWF CLI $(awf --version 2>&1) installed at $(command -v awf)"
SCRIPT

chmod +x /usr/local/bin/awf-install

echo "==> AWF CLI feature setup complete"
echo "    Run 'awf-install' or add it to postCreateCommand to download the binary"
