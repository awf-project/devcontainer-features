#!/bin/bash
set -e

# Scenario: install awf-cli latest (deferred install via awf-install helper)

echo "==> Testing AWF CLI latest scenario..."

# awf-install helper must be on PATH
if ! command -v awf-install &>/dev/null; then
    echo "FAIL: awf-install not found on PATH"
    exit 1
fi
echo "PASS: awf-install on PATH ($(command -v awf-install))"

# awf-install without gh auth should fail gracefully
OUTPUT=$(awf-install 2>&1 || true)
if echo "$OUTPUT" | grep -qE "(gh CLI|not authenticated|already installed)"; then
    echo "PASS: awf-install fails gracefully without gh auth"
else
    echo "FAIL: awf-install unexpected output: ${OUTPUT}"
    exit 1
fi

echo "==> AWF CLI latest scenario tests passed"
