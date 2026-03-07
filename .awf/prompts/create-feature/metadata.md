# Generate devcontainer-feature.json

Create the metadata file for a new devcontainer feature: **{{.inputs.description}}**

## Instructions

1. Read `src/rtk/devcontainer-feature.json` as reference patterns.
2. Create `src/{{trimSpace .states.validate_name.Output}}/devcontainer-feature.json` using the requirements below.

## Required Fields

| Field | Value |
|-------|-------|
| `id` | `{{trimSpace .states.validate_name.Output}}` |
| `version` | `1.0.0` |
| `name` | Capitalize each hyphen-separated word of the id (e.g. "mistral-vibe" → "Mistral Vibe") |
| `description` | One-line description derived from "{{.inputs.description}}" |
| `options.version` | `{ "type": "string", "default": "latest", "description": "Version to install: 'latest' or a specific version (e.g. '1.2.3')" }` |
| `installsAfter` | `["ghcr.io/devcontainers/features/common-utils"]` — use `dependsOn` instead if the feature cannot function without another feature |

## Optional Fields (add only when justified by the description)

- `documentationURL` / `licenseURL` — if inferable from the tool name
- `containerEnv` — if the tool requires PATH additions or environment variables
- `customizations.vscode.extensions` / `customizations.jetbrains.plugins` — if the tool has IDE integrations
- `mounts` + `postStartCommand` — if the tool needs persistent configuration (see `claude-code` for the pattern)
- Boolean `options` entries — only if the description implies optional sub-components

## Minimal Valid Output

```json
{
  "id": "{{trimSpace .states.validate_name.Output}}",
  "version": "1.0.0",
  "name": "<Capitalized Feature Name>",
  "description": "<concise one-liner>",
  "options": {
    "version": {
      "type": "string",
      "default": "latest",
      "description": "Version to install: 'latest' or a specific version (e.g. '1.2.3')"
    }
  },
  "installsAfter": ["ghcr.io/devcontainers/features/common-utils"]
}
```

Extend with optional fields as needed. JSON must be valid, 2-space indented.

## Constraints

- Write ONLY `src/{{trimSpace .states.validate_name.Output}}/devcontainer-feature.json`
- Do not create any other files
- Do not use Bash
