#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies Claude Code CLI is correctly installed and on PATH.

echo "==> Testing Claude Code feature..."

# claude binary must be on PATH
if ! command -v claude &>/dev/null; then
    echo "FAIL: claude not found on PATH"
    exit 1
fi
echo "PASS: claude on PATH ($(command -v claude))"

# claude --version must succeed and return a version string
CLAUDE_VERSION=$(claude --version 2>&1)
if [ -z "$CLAUDE_VERSION" ]; then
    echo "FAIL: claude --version returned empty output"
    exit 1
fi
echo "PASS: claude --version => ${CLAUDE_VERSION}"

echo "==> All Claude Code feature tests passed"
