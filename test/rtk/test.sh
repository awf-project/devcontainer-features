#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies RTK CLI is correctly installed and on PATH.

echo "==> Testing RTK feature..."

# rtk binary must be on PATH
if ! command -v rtk &>/dev/null; then
    echo "FAIL: rtk not found on PATH"
    exit 1
fi
echo "PASS: rtk on PATH ($(command -v rtk))"

# rtk --version must succeed and return a version string
RTK_VERSION=$(rtk --version 2>&1)
if [ -z "$RTK_VERSION" ]; then
    echo "FAIL: rtk --version returned empty output"
    exit 1
fi
echo "PASS: rtk --version => ${RTK_VERSION}"

echo "==> All RTK feature tests passed"
