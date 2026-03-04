#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> Clever Tools feature: version=${VERSION}"

# 1. Ensure dependencies
if ! command -v gpg &>/dev/null || ! command -v curl &>/dev/null; then
    echo "==> Installing missing dependencies..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates gnupg
    apt-get clean && rm -rf /var/lib/apt/lists/*
fi

# 2. Add Clever Cloud APT repository
echo "==> Adding Clever Cloud APT repository..."
curl -fsSL https://clever-tools.clever-cloud.com/gpg/cc-nexus-deb.public.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/cc-nexus-deb.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/cc-nexus-deb.gpg] https://nexus.clever-cloud.com/repository/deb stable main" \
    | tee /etc/apt/sources.list.d/clever-cloud.list > /dev/null

apt-get update -y

# 3. Install clever-tools
if [ "${VERSION}" = "latest" ]; then
    echo "==> Installing latest clever-tools..."
    apt-get install -y --no-install-recommends clever-tools
else
    echo "==> Installing clever-tools version ${VERSION}..."
    apt-get install -y --no-install-recommends "clever-tools=${VERSION}"
fi

# 4. Cleanup
apt-get clean && rm -rf /var/lib/apt/lists/*

# 5. Verify installation
echo "==> Clever Tools $(clever version) installed at $(command -v clever)"
echo "==> Clever Tools feature install complete"
