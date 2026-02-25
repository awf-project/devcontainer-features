#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-stable}"
PRECACHE_WEB="${PRECACHEWEB:-false}"
PRECACHE_LINUX="${PRECACHELINUX:-false}"
PRECACHE_ANDROID="${PRECACHEANDROID:-false}"

INSTALL_DIR="/opt/flutter"

# Ensure required dependencies are present
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* 2>/dev/null | head -1)" = "" ]; then
            echo "==> Running apt-get update..."
            apt-get update -y
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

check_packages curl ca-certificates xz-utils python3 git

# Resolve channel vs explicit version
# Known channels: stable, beta, master
resolve_channel_and_version() {
    case "$VERSION" in
        stable|beta|master)
            CHANNEL="$VERSION"
            PINNED_VERSION=""
            ;;
        *)
            # Explicit version like "3.27.4" — derive channel from releases API
            CHANNEL=$(curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json" \
                | python3 -c "
import json, sys
data = json.load(sys.stdin)
version = '${VERSION}'
for release in data['releases']:
    if release['version'] == version:
        print(release['channel'])
        break
else:
    print('ERROR: version not found', file=sys.stderr)
    sys.exit(1)
")
            PINNED_VERSION="$VERSION"
            ;;
    esac
}

# Fetch the latest version hash for a given channel
resolve_latest_version() {
    python3 -c "
import json, sys
data = json.load(sys.stdin)
channel = '${CHANNEL}'
for release in data['releases']:
    if release['channel'] == channel:
        print(release['version'])
        break
"
}

echo "==> Flutter feature: version=${VERSION} precache_web=${PRECACHE_WEB} precache_linux=${PRECACHE_LINUX} precache_android=${PRECACHE_ANDROID}"

resolve_channel_and_version

ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) ARCH_SUFFIX="" ;;
    arm64) ARCH_SUFFIX="arm64_" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

if [ -z "$PINNED_VERSION" ]; then
    RELEASES_JSON=$(curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json")
    PINNED_VERSION=$(echo "$RELEASES_JSON" | resolve_latest_version)
fi

echo "==> Installing Flutter ${PINNED_VERSION} (${CHANNEL}) for ${ARCH}..."

ARCHIVE="flutter_linux_${ARCH_SUFFIX}${PINNED_VERSION}-${CHANNEL}.tar.xz"
DOWNLOAD_URL="https://storage.googleapis.com/flutter_infra_release/releases/${CHANNEL}/linux/${ARCHIVE}"

echo "==> Downloading ${DOWNLOAD_URL}"
mkdir -p /opt
curl -fsSL "$DOWNLOAD_URL" | tar -xJ -C /opt

# The archive always extracts to /opt/flutter regardless of version
if [ ! -d "$INSTALL_DIR" ]; then
    echo "ERROR: Expected ${INSTALL_DIR} after extraction — archive layout changed?"
    ls /opt/
    exit 1
fi

# Add Flutter and Dart to PATH for all users (login + interactive shells)
cat > /etc/profile.d/flutter.sh << 'EOF'
export FLUTTER_HOME="/opt/flutter"
export PATH="${FLUTTER_HOME}/bin:${PATH}"
export PATH="${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"
EOF
chmod +x /etc/profile.d/flutter.sh

# Ensure non-login shells also pick up Flutter (bash + zsh)
if [ -f /etc/bash.bashrc ]; then
    echo 'source /etc/profile.d/flutter.sh' >> /etc/bash.bashrc
fi
if [ -f /etc/zsh/zshrc ]; then
    echo 'source /etc/profile.d/flutter.sh' >> /etc/zsh/zshrc
fi

# Mark flutter dir as safe for git (ownership may differ during Docker build)
git config --global --add safe.directory "$INSTALL_DIR"

export PATH="${INSTALL_DIR}/bin:${PATH}"
flutter config --no-analytics 2>/dev/null || true

echo "==> Flutter ${PINNED_VERSION} installed"
flutter --version

# Optional precache steps — each adds ~30-200 MB to image
if [ "${PRECACHE_WEB}" = "true" ]; then
    echo "==> Precaching web artifacts..."
    flutter precache --web
fi

if [ "${PRECACHE_LINUX}" = "true" ]; then
    echo "==> Precaching Linux desktop artifacts..."
    flutter precache --linux
fi

if [ "${PRECACHE_ANDROID}" = "true" ]; then
    echo "==> Precaching Android artifacts (requires Android SDK)..."
    flutter precache --android
fi

# Give remote user ownership so flutter can write its cache at runtime
REMOTE_USER="${_REMOTE_USER:-vscode}"
if id "$REMOTE_USER" &>/dev/null; then
    chown -R "${REMOTE_USER}:${REMOTE_USER}" "$INSTALL_DIR"
fi

echo "==> Flutter feature install complete"
