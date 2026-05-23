#!/bin/bash
set -e

# Scenario: install a specific AWF CLI version (v0.9.0)

source "$(dirname "$0")/test.sh"

# Verify the exact version matches
AWF_VERSION=$(awf version 2>&1 | head -1)
if [[ "$AWF_VERSION" != *"0.9.0"* ]]; then
    echo "FAIL: expected version 0.9.0, got: ${AWF_VERSION}"
    exit 1
fi
echo "PASS: awf version matches 0.9.0 => ${AWF_VERSION}"

echo "==> AWF CLI specific version tests passed"
