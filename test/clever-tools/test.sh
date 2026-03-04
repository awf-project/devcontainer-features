#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies Clever Tools is correctly installed and on PATH.

echo "==> Testing Clever Tools feature..."

# clever binary must be on PATH
if ! command -v clever &>/dev/null; then
    echo "FAIL: clever not found on PATH"
    exit 1
fi
echo "PASS: clever on PATH ($(command -v clever))"

# clever version must succeed and return a version string
CLEVER_VERSION=$(clever version 2>&1)
if [ -z "$CLEVER_VERSION" ]; then
    echo "FAIL: clever version returned empty output"
    exit 1
fi
echo "PASS: clever version => ${CLEVER_VERSION}"

# clever binary must be installed by apt (typically /usr/bin)
CLEVER_PATH=$(command -v clever)
if [ ! -x "${CLEVER_PATH}" ]; then
    echo "FAIL: clever binary not executable at ${CLEVER_PATH}"
    exit 1
fi
echo "PASS: clever installed at ${CLEVER_PATH}"

echo "==> All Clever Tools feature tests passed"
