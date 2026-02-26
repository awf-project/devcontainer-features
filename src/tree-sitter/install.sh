#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"
GRAMMAR_PHP="${GRAMMARPHP:-false}"
GRAMMAR_TYPESCRIPT="${GRAMMARTYPESCRIPT:-false}"
GRAMMAR_JAVASCRIPT="${GRAMMARJAVASCRIPT:-false}"
GRAMMAR_GO="${GRAMMARGO:-false}"
GRAMMAR_DART="${GRAMMARDART:-false}"
GRAMMAR_PYTHON="${GRAMMARPYTHON:-false}"
GRAMMAR_YAML="${GRAMMARYAML:-false}"

TREE_SITTER_DIR="/usr/local/lib/tree-sitter"

# --- Helpers ---
check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* 2>/dev/null | head -1)" = "" ]; then
            echo "==> Running apt-get update..."
            apt-get update -y
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

any_grammar_enabled() {
    [ "$GRAMMAR_PHP" = "true" ] || [ "$GRAMMAR_TYPESCRIPT" = "true" ] || \
    [ "$GRAMMAR_JAVASCRIPT" = "true" ] || [ "$GRAMMAR_GO" = "true" ] || \
    [ "$GRAMMAR_DART" = "true" ] || [ "$GRAMMAR_PYTHON" = "true" ] || \
    [ "$GRAMMAR_YAML" = "true" ]
}

# Clone a grammar repo, build the .so, clean up.
# Usage: build_grammar <github-org/repo> <output-name> [subdir]
build_grammar() {
    local repo="$1"
    local name="$2"
    local subdir="${3:-}"
    local clone_dir="/tmp/ts-${name}"

    echo "==> Building grammar: ${name} (${repo})..."
    git clone --depth 1 "https://github.com/${repo}.git" "$clone_dir"

    local build_dir="$clone_dir"
    if [ -n "$subdir" ]; then
        build_dir="${clone_dir}/${subdir}"
    fi

    tree-sitter build --output "${TREE_SITTER_DIR}/${name}.so" "$build_dir"
    rm -rf "$clone_dir"
    echo "==> Grammar ${name} installed: ${TREE_SITTER_DIR}/${name}.so"
}

# --- Main ---
echo "==> Tree-sitter feature: version=${VERSION}"

# 1. Base dependencies
check_packages curl ca-certificates

# 2. Resolve version
if [ "$VERSION" = "latest" ]; then
    # NOTE: Anonymous GitHub API rate limit is 60 req/hour.
    # If builds fail here, pin a specific version instead.
    VERSION=$(curl -fsSL "https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest" \
        | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
    if [ -z "$VERSION" ]; then
        echo "ERROR: Failed to resolve latest tree-sitter version from GitHub API"
        exit 1
    fi
    echo "==> Resolved latest version: ${VERSION}"
fi

# 3. Download pre-built CLI binary
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    amd64) TS_ARCH="x64" ;;
    arm64) TS_ARCH="arm64" ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

DOWNLOAD_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v${VERSION}/tree-sitter-linux-${TS_ARCH}.gz"
echo "==> Downloading tree-sitter v${VERSION} for ${TS_ARCH}..."
curl -fsSL "$DOWNLOAD_URL" | gunzip > /usr/local/bin/tree-sitter
chmod +x /usr/local/bin/tree-sitter

echo "==> Tree-sitter $(tree-sitter --version) installed at $(command -v tree-sitter)"

# 4. Grammar compilation (only if at least one grammar is enabled)
if any_grammar_enabled; then
    echo "==> Installing build dependencies for grammars..."
    check_packages gcc libc6-dev git

    mkdir -p "$TREE_SITTER_DIR"

    if [ "$GRAMMAR_PHP" = "true" ]; then
        build_grammar "tree-sitter/tree-sitter-php" "php" "php"
    fi
    if [ "$GRAMMAR_TYPESCRIPT" = "true" ]; then
        build_grammar "tree-sitter/tree-sitter-typescript" "typescript" "typescript"
    fi
    if [ "$GRAMMAR_JAVASCRIPT" = "true" ]; then
        build_grammar "tree-sitter/tree-sitter-javascript" "javascript"
    fi
    if [ "$GRAMMAR_GO" = "true" ]; then
        build_grammar "tree-sitter/tree-sitter-go" "go"
    fi
    if [ "$GRAMMAR_DART" = "true" ]; then
        build_grammar "UserNobody14/tree-sitter-dart" "dart"
    fi
    if [ "$GRAMMAR_PYTHON" = "true" ]; then
        build_grammar "tree-sitter/tree-sitter-python" "python"
    fi
    if [ "$GRAMMAR_YAML" = "true" ]; then
        build_grammar "tree-sitter-grammars/tree-sitter-yaml" "yaml"
    fi

    # Give remote user ownership so tree-sitter can write at runtime
    REMOTE_USER="${_REMOTE_USER:-vscode}"
    if id "$REMOTE_USER" &>/dev/null; then
        chown -R "${REMOTE_USER}:${REMOTE_USER}" "$TREE_SITTER_DIR"
    fi
fi

echo "==> Tree-sitter feature install complete"
