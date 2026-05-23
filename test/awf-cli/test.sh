#!/bin/bash
set -e

echo "==> Testing AWF CLI feature..."

# awf binary must be on PATH
if ! command -v awf &>/dev/null; then
    echo "FAIL: awf not found on PATH"
    exit 1
fi
echo "PASS: awf on PATH ($(command -v awf))"

# awf version must succeed and return a version string
AWF_VERSION=$(awf version 2>&1 | head -1)
if [ -z "$AWF_VERSION" ]; then
    echo "FAIL: awf version returned empty output"
    exit 1
fi
echo "PASS: awf version => ${AWF_VERSION}"

echo "==> All AWF CLI feature tests passed"
