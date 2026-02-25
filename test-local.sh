#!/bin/bash
set -e

# Local test runner for devcontainer features
# Requires: devcontainer CLI (npm install -g @devcontainers/cli) and Docker

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FEATURE="${1:-flutter}"
SCENARIO="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_prerequisites() {
    if ! command -v devcontainer &>/dev/null; then
        echo -e "${RED}devcontainer CLI not found${NC}"
        echo "Install with: npm install -g @devcontainers/cli"
        exit 1
    fi
    if ! docker info &>/dev/null 2>&1; then
        echo -e "${RED}Docker is not running${NC}"
        exit 1
    fi
}

run_tests() {
    local args=(
        --features "$FEATURE"
        --project-folder "$SCRIPT_DIR"
    )

    if [ -n "$SCENARIO" ]; then
        args+=(--filter "$SCENARIO")
    fi

    echo -e "${YELLOW}==> Testing feature: ${FEATURE}${NC}"
    if [ -n "$SCENARIO" ]; then
        echo -e "${YELLOW}==> Scenario: ${SCENARIO}${NC}"
    else
        echo -e "${YELLOW}==> Running all scenarios from test/${FEATURE}/scenarios.json${NC}"
    fi
    echo ""

    if devcontainer features test "${args[@]}"; then
        echo ""
        echo -e "${GREEN}==> All tests passed${NC}"
    else
        echo ""
        echo -e "${RED}==> Tests failed${NC}"
        exit 1
    fi
}

check_prerequisites
run_tests
