#!/bin/bash
set -e

# Scenario: install_mistral_vibe_specific_version
# Validates installation of a pinned version (2.2.1).

source "$(dirname "$0")/test.sh"

# Verify the exact version matches
VIBE_VERSION=$(vibe --version 2>&1)
if [[ "$VIBE_VERSION" != *"2.2.1"* ]]; then
    echo "FAIL: expected version 2.2.1, got: ${VIBE_VERSION}"
    exit 1
fi
echo "PASS: vibe version matches 2.2.1 => ${VIBE_VERSION}"

echo "==> Mistral Vibe specific version tests passed"
