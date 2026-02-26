#!/bin/bash
set -e

echo "==> GrepAI feature: installing..."

# Ensure curl is available (minimal images may not have it)
if ! command -v curl &>/dev/null; then
    echo "==> curl not found, installing..."
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates
fi

# Install GrepAI via official installer
curl -sSL https://raw.githubusercontent.com/yoanbernabeu/grepai/main/install.sh | sh

# The installer places the binary in ~/.local/bin.
# Copy it to /usr/local/bin so all container users can access it regardless
# of home directory permissions (e.g. /root is 700).
GREPAI_BIN="$HOME/.local/bin/grepai"
if [ ! -f "$GREPAI_BIN" ]; then
    # Some builds may install directly to /usr/local/bin — check before failing
    if ! command -v grepai &>/dev/null; then
        echo "ERROR: grepai binary not found after install. Checked: $GREPAI_BIN"
        exit 1
    fi
else
    install -m 0755 "$GREPAI_BIN" /usr/local/bin/grepai
fi

echo "==> GrepAI $(grepai version) installed at $(command -v grepai)"

# Install the post-start script that displays quickstart guidance
install -m 0755 ./grepai-quickstart.sh /usr/local/bin/grepai-quickstart

echo "==> GrepAI feature install complete"
