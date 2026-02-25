#!/bin/sh
set -eu

# Auto-detect the current user
username="$(whoami 2>/dev/null || true)"

# No username detected? Exit gracefully (volume still mounted at /claude-config)
[ -n "$username" ] || exit 0

# Find home directory for that user
home_dir="$(getent passwd "$username" | cut -d: -f6 || true)"
if [ -z "$home_dir" ]; then
  echo "claude-config: user '$username' not found; skipping" >&2
  exit 0
fi

mkdir -p "$home_dir"

# Create/replace symlink: ~/.claude -> /claude-config
echo "claude-config: $home_dir/.claude -> /claude-config" >&2
ln -snf /claude-config "$home_dir/.claude"

# Persist ~/.claude.json inside the volume and symlink it
config_file="/claude-config/claude.json"
target_file="$home_dir/.claude.json"
if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
  # First run: move existing file into the volume
  mv "$target_file" "$config_file"
fi
touch "$config_file"
echo "claude-config: $target_file -> $config_file" >&2
ln -snf "$config_file" "$target_file"
