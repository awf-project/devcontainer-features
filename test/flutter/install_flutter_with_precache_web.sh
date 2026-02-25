#!/bin/bash
set -e

# Scenario: install_flutter_with_precache_web
# Verifies installation with web precache enabled.

source "$(dirname "$0")/test.sh"

# Additional check: web artifacts should be precached
if [ ! -d "/opt/flutter/bin/cache/flutter_web_sdk" ]; then
    echo "FAIL: Web SDK not precached (flutter_web_sdk missing)"
    exit 1
fi
echo "PASS: Web artifacts precached"
