#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> Claude Code feature: version=${VERSION}"

# Node.js and npm are required — install if missing
if ! command -v npm &>/dev/null; then
    echo "==> npm not found, installing Node.js..."
    apt-get update
    apt-get install -y curl ca-certificates gnupg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list
    apt-get update
    apt-get install -y nodejs
fi

echo "==> npm version: $(npm --version)"
echo "==> node version: $(node --version)"

# Build the npm package reference: latest or pinned
if [ "$VERSION" = "latest" ]; then
    NPM_PACKAGE="@anthropic-ai/claude-code"
else
    NPM_PACKAGE="@anthropic-ai/claude-code@${VERSION}"
fi

echo "==> Installing ${NPM_PACKAGE}..."
npm install -g "$NPM_PACKAGE"

# Verify the binary is accessible
if ! command -v claude &>/dev/null; then
    echo "ERROR: 'claude' binary not found on PATH after install."
    echo "npm global bin: $(npm bin -g 2>/dev/null || echo 'unknown')"
    exit 1
fi

echo "==> Claude Code $(claude --version) installed at $(command -v claude)"
echo "==> Claude Code feature install complete"
