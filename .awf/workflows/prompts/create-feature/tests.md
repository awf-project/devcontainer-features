# Generate Test Files

Create test files for a devcontainer feature: **{{.inputs.description}}**

Feature ID: `{{trimSpace .states.validate_name.Output}}`

## Inputs to Read First

1. `src/{{trimSpace .states.validate_name.Output}}/devcontainer-feature.json` — options, containerEnv
2. `src/{{trimSpace .states.validate_name.Output}}/install.sh` — binary name, default version
3. Reference tests:
   - `test/rtk/test.sh` — minimal PATH + version assertions
   - `test/rtk/scenarios.json` — version-pinned scenario
   - `test/rtk/install_rtk_specific_version.sh` — exact version string check pattern
   - `test/claude-code/test.sh` — extended assertions (binary location, env vars)
   - `test/claude-code/scenarios.json` — two-scenario structure (latest + pinned)

## Files to Create

### `test/{{trimSpace .states.validate_name.Output}}/test.sh`

Assertions (in order):
1. Binary on PATH: `command -v <binary>`
2. Version output non-empty: `<BINARY>_VERSION=$(<binary> --version 2>&1)`
3. For each entry in `containerEnv`: assert variable is set and non-empty
4. Any feature-specific file or path checks (derive from install.sh)

Output format: `PASS: <description>` or `FAIL: <description>` then `exit 1`
Final line: `echo "==> All <Feature Name> feature tests passed"` (capitalize each word of the feature ID for the human-readable name)

### `test/{{trimSpace .states.validate_name.Output}}/scenarios.json`

Minimum scenarios (use the feature ID with hyphens replaced by underscores for scenario keys):

```json
{
  "install_<feature_id_underscored>_latest": {
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": { "<feature_id>": {} }
  },
  "install_<feature_id_underscored>_specific_version": {
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": { "<feature_id>": { "version": "<real_semver_from_install.sh>" } }
  }
}
```

For each boolean option in `devcontainer-feature.json`, add:
```json
"install_<feature_id_underscored>_with_<option>": {
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": { "<feature_id>": { "<option>": true } }
}
```

For the `version` field: use a real semver found in `install.sh` (default value or recent stable), never a placeholder.

### Scenario Scripts (one `.sh` per scenario key)

- `_latest`: source `"$(dirname "$0")/test.sh"` — no extra assertions
- `_specific_version`: source `test.sh`, then verify exact version string matches the pinned value
- `_with_<option>`: source `test.sh`, then assert the optional component is installed

## Constraints

- Scripts: `#!/bin/bash`, `set -e`
- Tests must be idempotent — no container state modification
- Image: always `mcr.microsoft.com/devcontainers/base:ubuntu`
- File names must match scenario keys in `scenarios.json` exactly
- Write only to `test/{{trimSpace .states.validate_name.Output}}/`
- Do not modify existing files
- Do not run shell commands — ShellCheck runs as a separate pipeline step
