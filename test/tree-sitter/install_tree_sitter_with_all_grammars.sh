#!/bin/bash
set -e

# Scenario: install tree-sitter with all grammars
source "$(dirname "$0")/test.sh"

GRAMMARS="php typescript javascript go dart python yaml"
for grammar in $GRAMMARS; do
    if [ ! -f "${TREE_SITTER_DIR}/${grammar}.so" ]; then
        echo "FAIL: ${grammar} grammar not found at ${TREE_SITTER_DIR}/${grammar}.so"
        exit 1
    fi
    echo "PASS: ${grammar} grammar installed"
done

echo "==> All grammar tests passed"
