#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> Claude Code feature: version=${VERSION}"

# Ensure curl is available (minimal images may not have it)
if ! command -v curl &>/dev/null; then
    echo "==> curl not found, installing..."
    apt-get update
    apt-get install -y curl ca-certificates
fi

# Install Claude Code via official installer
if [ "$VERSION" = "latest" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    curl -fsSL https://claude.ai/install.sh | bash -s -- "$VERSION"
fi

# The installer places the binary in ~/.local/bin (under the build user's $HOME).
# Copy it to /usr/local/bin so all container users can access it regardless of
# home directory permissions (e.g. /root is 700).
CLAUDE_BIN="$HOME/.local/bin/claude"
if [ ! -f "$CLAUDE_BIN" ]; then
    echo "ERROR: expected binary at $CLAUDE_BIN not found after install."
    exit 1
fi
install -m 0755 "$CLAUDE_BIN" /usr/local/bin/claude

echo "==> Claude Code $(claude --version) installed at $(command -v claude)"

# Pre-create the volume mount point with correct ownership so that Docker
# named volumes inherit the ownership on first use (no sudo needed later).
if [ -n "${_REMOTE_USER:-}" ]; then
    mkdir -p /claude-config
    chown "$_REMOTE_USER:$_REMOTE_USER" /claude-config
fi

# Install the post-start script for persistent storage symlink
install -d /usr/local/bin
install -m 0755 ./link-claude-config.sh /usr/local/bin/link-claude-config

echo "==> Claude Code feature install complete"
