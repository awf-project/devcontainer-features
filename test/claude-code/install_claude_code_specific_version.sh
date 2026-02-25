#!/bin/bash
set -e

# Scenario: install_claude_code_specific_version
# Verifies pinned version (2.1.30) installation works.

source "$(dirname "$0")/test.sh"

# Additional check: verify the exact version was installed
INSTALLED=$(npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null | grep @anthropic-ai/claude-code | grep -oP '\d+\.\d+\.\d+')
EXPECTED="2.1.30"
if [ "$INSTALLED" != "$EXPECTED" ]; then
    echo "FAIL: Expected @anthropic-ai/claude-code@${EXPECTED}, got ${INSTALLED}"
    exit 1
fi
echo "PASS: Correct version ${EXPECTED} installed"
