#!/bin/bash
set -e

# Scenario: install a specific RTK version (0.23.0)

echo "==> Testing RTK specific version scenario..."

# rtk binary must be on PATH
if ! command -v rtk &>/dev/null; then
    echo "FAIL: rtk not found on PATH"
    exit 1
fi
echo "PASS: rtk on PATH ($(command -v rtk))"

# Verify the exact version matches
RTK_VERSION=$(rtk --version 2>&1)
if [[ "$RTK_VERSION" != *"0.22.2"* ]]; then
    echo "FAIL: expected version 0.22.2, got: ${RTK_VERSION}"
    exit 1
fi
echo "PASS: rtk version matches 0.22.2 => ${RTK_VERSION}"

echo "==> RTK specific version tests passed"
