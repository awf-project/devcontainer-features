#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Local integration test for devcontainer features
#
# Builds a temporary project with a devcontainer.json referencing a
# local feature, spins up the container, runs test assertions, and
# cleans up.
#
# Usage: ./test-integration.sh <feature> [--keep]
#   --keep : keep container alive after tests (for debugging)
#
# Requires: devcontainer CLI (npm install -g @devcontainers/cli)
# -------------------------------------------------------------------

FEATURE="${1:?Usage: $0 <feature> [--keep]}"
KEEP=false
[[ "${2:-}" == "--keep" ]] && KEEP=true

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FEATURE_SRC="${REPO_ROOT}/src/${FEATURE}"
TEST_SCRIPT="${REPO_ROOT}/test/${FEATURE}/test.sh"

# Validate inputs
if [[ ! -d "$FEATURE_SRC" ]]; then
  echo "ERROR: Feature '${FEATURE}' not found in src/" >&2
  exit 1
fi

if [[ ! -f "$TEST_SCRIPT" ]]; then
  echo "ERROR: No test script at test/${FEATURE}/test.sh" >&2
  exit 1
fi

# Check devcontainer CLI
if ! command -v devcontainer &>/dev/null; then
  echo "ERROR: devcontainer CLI not found. Install with: npm install -g @devcontainers/cli" >&2
  exit 1
fi

# Create temp project with copied feature source
TMPDIR="$(mktemp -d)"
WORKSPACE="${TMPDIR}/project"
mkdir -p "${WORKSPACE}/.devcontainer"
cp -r "${FEATURE_SRC}" "${WORKSPACE}/.devcontainer/${FEATURE}"

cat > "${WORKSPACE}/.devcontainer/devcontainer.json" <<EOF
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "./${FEATURE}": {}
  }
}
EOF

echo "==> Testing feature '${FEATURE}'"
echo "    Workspace: ${WORKSPACE}"
echo "    Feature source: ${FEATURE_SRC}"

# Build and start the container
echo "==> Building devcontainer..."
devcontainer up --log-level debug --build-no-cache --workspace-folder "${WORKSPACE}"

# Run test assertions inside the container
echo "==> Running test/${FEATURE}/test.sh..."
devcontainer exec --workspace-folder "${WORKSPACE}" bash -c "$(cat "$TEST_SCRIPT")"

TEST_EXIT=$?

# Cleanup
if [[ "$KEEP" == true ]]; then
  echo "==> Container kept alive (--keep). Workspace: ${WORKSPACE}"
  echo "    To clean up manually:"
  echo "      devcontainer down --workspace-folder ${WORKSPACE}"
  echo "      rm -rf ${TMPDIR}"
else
  echo "==> Cleaning up..."
  devcontainer down --workspace-folder "${WORKSPACE}" 2>/dev/null || true
  rm -rf "${TMPDIR}"
fi

if [[ $TEST_EXIT -eq 0 ]]; then
  echo "==> PASSED: ${FEATURE}"
else
  echo "==> FAILED: ${FEATURE}" >&2
  exit $TEST_EXIT
fi
