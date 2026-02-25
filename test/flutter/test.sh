#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies Flutter SDK is correctly installed and on PATH.

echo "==> Testing Flutter feature..."

# Flutter binary must be on PATH
if ! command -v flutter &>/dev/null; then
    echo "FAIL: flutter not found on PATH"
    exit 1
fi
echo "PASS: flutter on PATH ($(command -v flutter))"

# Dart binary must be on PATH (bundled with Flutter)
if ! command -v dart &>/dev/null; then
    echo "FAIL: dart not found on PATH"
    exit 1
fi
echo "PASS: dart on PATH ($(command -v dart))"

# FLUTTER_HOME env var must be set
if [ -z "$FLUTTER_HOME" ]; then
    echo "FAIL: FLUTTER_HOME not set"
    exit 1
fi
echo "PASS: FLUTTER_HOME=${FLUTTER_HOME}"

# Flutter directory must exist
if [ ! -d "$FLUTTER_HOME" ]; then
    echo "FAIL: FLUTTER_HOME directory does not exist: ${FLUTTER_HOME}"
    exit 1
fi
echo "PASS: FLUTTER_HOME directory exists"

# flutter --version must succeed (also triggers Dart SDK download if needed)
flutter --version
echo "PASS: flutter --version succeeded"

# dart --version must succeed
dart --version
echo "PASS: dart --version succeeded"

echo "==> All Flutter feature tests passed"
