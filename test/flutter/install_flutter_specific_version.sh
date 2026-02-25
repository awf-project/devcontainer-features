#!/bin/bash
set -e

# Scenario: install_flutter_specific_version
# Verifies pinned version (3.27.4) installation works.

source "$(dirname "$0")/test.sh"

# Additional check: verify the exact version was installed
INSTALLED_VERSION=$(flutter --version | head -1 | grep -oP '\d+\.\d+\.\d+')
EXPECTED="3.27.4"
if [ "$INSTALLED_VERSION" != "$EXPECTED" ]; then
    echo "FAIL: Expected Flutter ${EXPECTED}, got ${INSTALLED_VERSION}"
    exit 1
fi
echo "PASS: Correct version ${EXPECTED} installed"
