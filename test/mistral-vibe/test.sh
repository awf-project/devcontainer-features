#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies Mistral Vibe is correctly installed and on PATH.

echo "==> Testing Mistral Vibe feature..."

# vibe binary must be on PATH
if ! command -v vibe &>/dev/null; then
    echo "FAIL: vibe not found on PATH"
    exit 1
fi
echo "PASS: vibe on PATH ($(command -v vibe))"

# vibe --version must succeed and return a version string
VIBE_VERSION=$(vibe --version 2>&1)
if [ -z "$VIBE_VERSION" ]; then
    echo "FAIL: vibe --version returned empty output"
    exit 1
fi
echo "PASS: vibe --version => ${VIBE_VERSION}"

# vibe must exist in /usr/local/bin
if [ ! -f /usr/local/bin/vibe ]; then
    echo "FAIL: /usr/local/bin/vibe does not exist"
    exit 1
fi
echo "PASS: /usr/local/bin/vibe exists"

echo "==> All Mistral Vibe feature tests passed"
