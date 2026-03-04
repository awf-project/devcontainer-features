#!/bin/bash
set -e

# Scenario: install_clever_tools_specific_version
# Verifies Clever Tools installs the exact pinned version

source "$(dirname "$0")/test.sh"

# Verify the exact version matches
CLEVER_VERSION=$(clever version 2>&1)
if [[ "$CLEVER_VERSION" != *"4.6.0"* ]]; then
    echo "FAIL: expected version 4.6.0, got: ${CLEVER_VERSION}"
    exit 1
fi
echo "PASS: clever version matches 4.6.0 => ${CLEVER_VERSION}"

echo "==> Clever Tools specific version tests passed"
