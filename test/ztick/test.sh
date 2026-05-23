#!/bin/bash
set -e

echo "==> Testing Ztick feature..."

# ztick binary must be on PATH
if ! command -v ztick &>/dev/null; then
    echo "FAIL: ztick not found on PATH"
    exit 1
fi
echo "PASS: ztick on PATH ($(command -v ztick))"

# ztick --version must succeed and return a version string
ZTICK_VERSION=$(ztick --version 2>&1)
if [ -z "$ZTICK_VERSION" ]; then
    echo "FAIL: ztick --version returned empty output"
    exit 1
fi
echo "PASS: ztick --version => ${ZTICK_VERSION}"

echo "==> All Ztick feature tests passed"
