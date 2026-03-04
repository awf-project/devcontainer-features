#!/bin/bash
set -e

# validate-name.sh — Derive or validate a devcontainer feature name
#
# Inputs (AWF interpolation):
#   {{.inputs.description}} - Feature description (required)
#   {{.inputs.name}}        - Feature name override (optional, kebab-case)
#
# Output (stdout): plain feature ID (kebab-case, e.g. "zellij")

DESCRIPTION="{{.inputs.description}}"
NAME="{{.inputs.name}}"

if [ -z "$DESCRIPTION" ]; then
    echo "ERROR: DESCRIPTION is required"
    exit 1
fi

# Derive name from description if not provided
if [ -z "$NAME" ]; then
    # Extract the tool/project name: take the word after "Installs" or first capitalized word
    NAME=$(echo "$DESCRIPTION" \
        | sed -E 's/^[Ii]nstalls?\s+//' \
        | sed -E 's/^(the\s+|a\s+|an\s+)//i' \
        | awk '{print $1}' \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9-]//g')
fi

# Validate: must be non-empty kebab-case
if [ -z "$NAME" ]; then
    echo "ERROR: could not derive feature name from description: ${DESCRIPTION}"
    exit 1
fi

if ! echo "$NAME" | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$'; then
    # Single char names are also valid
    if ! echo "$NAME" | grep -qE '^[a-z]$'; then
        echo "ERROR: invalid feature name '${NAME}' — must be kebab-case (lowercase, hyphens, start with letter)"
        exit 1
    fi
fi

# Output just the ID (no JSON — output_format: json is only supported on agent steps)
printf '%s' "$NAME"
