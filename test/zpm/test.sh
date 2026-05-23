#!/bin/bash
set -e

echo "==> Testing ZPM feature..."

# zpm binary must be on PATH
if ! command -v zpm &>/dev/null; then
    echo "FAIL: zpm not found on PATH"
    exit 1
fi
echo "PASS: zpm on PATH ($(command -v zpm))"

# zpm --version must succeed and return a version string
ZPM_VERSION=$(zpm version 2>&1)
if [ -z "$ZPM_VERSION" ]; then
    echo "FAIL: zpm --version returned empty output"
    exit 1
fi
echo "PASS: zpm --version => ${ZPM_VERSION}"

echo "==> All ZPM feature tests passed"
