#!/bin/bash
set -e

# Scenario: install a specific ZPM version (v0.3.0)

echo "==> Testing ZPM specific version scenario..."

# zpm binary must be on PATH
if ! command -v zpm &>/dev/null; then
    echo "FAIL: zpm not found on PATH"
    exit 1
fi
echo "PASS: zpm on PATH ($(command -v zpm))"

# Verify the exact version matches
ZPM_VERSION=$(zpm version 2>&1)
if [[ "$ZPM_VERSION" != *"0.3.0"* ]]; then
    echo "FAIL: expected version 0.3.0, got: ${ZPM_VERSION}"
    exit 1
fi
echo "PASS: zpm version matches 0.3.0 => ${ZPM_VERSION}"

echo "==> ZPM specific version tests passed"
