#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies GrepAI CLI is correctly installed and on PATH.

echo "==> Testing GrepAI feature..."

# grepai binary must be on PATH
if ! command -v grepai &>/dev/null; then
    echo "FAIL: grepai not found on PATH"
    exit 1
fi
echo "PASS: grepai on PATH ($(command -v grepai))"

# grepai version must succeed and return a version string
GREPAI_VERSION=$(grepai version 2>&1)
if [ -z "$GREPAI_VERSION" ]; then
    echo "FAIL: grepai version returned empty output"
    exit 1
fi
echo "PASS: grepai version => ${GREPAI_VERSION}"

echo "==> All GrepAI feature tests passed"
