#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Since awf-cli is a private repo, we can only verify the install helper
# is correctly set up (not the actual binary download, which requires gh auth).

echo "==> Testing AWF CLI feature..."

# awf-install helper must be on PATH
if ! command -v awf-install &>/dev/null; then
    echo "FAIL: awf-install not found on PATH"
    exit 1
fi
echo "PASS: awf-install on PATH ($(command -v awf-install))"

# awf-install must be executable
if [ ! -x "$(command -v awf-install)" ]; then
    echo "FAIL: awf-install is not executable"
    exit 1
fi
echo "PASS: awf-install is executable"

# awf-install without gh auth should fail gracefully (not crash)
OUTPUT=$(awf-install 2>&1 || true)
if echo "$OUTPUT" | grep -qE "(gh CLI|not authenticated|already installed)"; then
    echo "PASS: awf-install fails gracefully without gh auth"
else
    echo "FAIL: awf-install unexpected output: ${OUTPUT}"
    exit 1
fi

echo "==> All AWF CLI feature tests passed"
