#!/bin/bash
set -e

# Scenario: install tree-sitter with PHP grammar
source "$(dirname "$0")/test.sh"

# PHP grammar .so must exist
if [ ! -f "${TREE_SITTER_DIR}/php.so" ]; then
    echo "FAIL: PHP grammar not found at ${TREE_SITTER_DIR}/php.so"
    exit 1
fi
echo "PASS: PHP grammar installed at ${TREE_SITTER_DIR}/php.so"
