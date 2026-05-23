#!/bin/bash
set -e

# Scenario: install a specific Ztick version (v0.3.0)

source "$(dirname "$0")/test.sh"

# Verify the exact version matches
ZTICK_VERSION=$(ztick --version 2>&1)
if [[ "$ZTICK_VERSION" != *"0.3.0"* ]]; then
    echo "FAIL: expected version 0.3.0, got: ${ZTICK_VERSION}"
    exit 1
fi
echo "PASS: ztick version matches 0.3.0 => ${ZTICK_VERSION}"

echo "==> Ztick specific version tests passed"
