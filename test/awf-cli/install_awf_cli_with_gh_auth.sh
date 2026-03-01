#!/bin/bash
set -e

# Scenario: install awf-cli with gh authenticated
# Requires GH_TOKEN env var with access to awf-project/cli private repo.
# Skips gracefully if no token is available (e.g. in public CI).

echo "==> Testing AWF CLI with gh auth scenario..."

# awf-install must exist
if ! command -v awf-install &>/dev/null; then
    echo "FAIL: awf-install not found on PATH"
    exit 1
fi
echo "PASS: awf-install on PATH"

# gh must be available (installed via github-cli feature)
if ! command -v gh &>/dev/null; then
    echo "FAIL: gh CLI not found on PATH"
    exit 1
fi
echo "PASS: gh on PATH ($(command -v gh))"

# Skip actual download if gh is not authenticated
if ! gh auth status &>/dev/null 2>&1; then
    echo "SKIP: gh not authenticated — skipping binary download test"
    echo "==> AWF CLI with gh auth scenario tests passed (partial)"
    exit 0
fi
echo "PASS: gh is authenticated"

# Run awf-install to download the binary
awf-install

# awf binary must be on PATH
if ! command -v awf &>/dev/null; then
    echo "FAIL: awf not found on PATH after awf-install"
    exit 1
fi
echo "PASS: awf on PATH ($(command -v awf))"

# awf --version must succeed
AWF_VERSION=$(awf --version 2>&1)
if [ -z "$AWF_VERSION" ]; then
    echo "FAIL: awf --version returned empty output"
    exit 1
fi
echo "PASS: awf --version => ${AWF_VERSION}"

echo "==> AWF CLI with gh auth scenario tests passed"
