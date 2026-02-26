#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies Tree-sitter CLI is correctly installed and on PATH.

echo "==> Testing Tree-sitter feature..."

# tree-sitter binary must be on PATH
if ! command -v tree-sitter &>/dev/null; then
    echo "FAIL: tree-sitter not found on PATH"
    exit 1
fi
echo "PASS: tree-sitter on PATH ($(command -v tree-sitter))"

# tree-sitter --version must succeed
TS_VERSION=$(tree-sitter --version 2>&1)
if [ -z "$TS_VERSION" ]; then
    echo "FAIL: tree-sitter --version returned empty output"
    exit 1
fi
echo "PASS: tree-sitter --version => ${TS_VERSION}"

# TREE_SITTER_DIR env var must be set
if [ -z "$TREE_SITTER_DIR" ]; then
    echo "FAIL: TREE_SITTER_DIR not set"
    exit 1
fi
echo "PASS: TREE_SITTER_DIR=${TREE_SITTER_DIR}"

echo "==> All Tree-sitter base tests passed"
