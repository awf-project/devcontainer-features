#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> Mistral Vibe feature: version=${VERSION}"

# 1. Ensure curl is available
if ! command -v curl &>/dev/null; then
    echo "==> Installing missing dependencies..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates
    apt-get clean && rm -rf /var/lib/apt/lists/*
fi

# 2. Install uv if not present (Python package installer from Astral)
if ! command -v uv &>/dev/null; then
    echo "==> Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # uv installer puts binary in ~/.local/bin — make it available system-wide
    if [ -f "${HOME}/.local/bin/uv" ]; then
        ln -sf "${HOME}/.local/bin/uv" /usr/local/bin/uv
    fi
fi

if ! command -v uv &>/dev/null; then
    echo "ERROR: uv installation failed — cannot proceed"
    exit 1
fi
echo "==> uv $(uv --version) available"

# 3. Install mistral-vibe via uv tool to shared paths
#    Default uv tool install goes to ~/.local which is root-only (700).
#    Redirect everything to /usr/local so all users can access:
#    - UV_TOOL_DIR: virtualenvs for uv tools
#    - UV_TOOL_BIN_DIR: wrapper scripts (entry points)
#    - UV_PYTHON_INSTALL_DIR: uv-managed Python interpreters
#      (without this, the virtualenv python symlinks resolve to /root/.local/share/uv/python/)
export UV_TOOL_DIR=/usr/local/share/uv/tools
export UV_TOOL_BIN_DIR=/usr/local/bin
export UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python

if [ "${VERSION}" = "latest" ]; then
    echo "==> Installing mistral-vibe (latest)..."
    uv tool install mistral-vibe
else
    echo "==> Installing mistral-vibe version ${VERSION}..."
    uv tool install "mistral-vibe==${VERSION}"
fi

# 4. Ensure all uv-managed paths are accessible by all users
chmod -R a+rX "${UV_TOOL_DIR}" "${UV_PYTHON_INSTALL_DIR}"

# 5. Verify installation
if ! command -v vibe &>/dev/null; then
    echo "ERROR: vibe not found on PATH after installation"
    exit 1
fi

VIBE_VERSION=$(vibe --version 2>&1) || true
if [ -z "${VIBE_VERSION}" ]; then
    echo "ERROR: vibe --version returned empty output"
    exit 1
fi
echo "==> Mistral Vibe ${VIBE_VERSION} installed at $(command -v vibe)"

echo "==> Mistral Vibe feature install complete"
