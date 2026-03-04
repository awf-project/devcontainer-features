# Devcontainer Features

Custom devcontainer features published to GHCR (`ghcr.io/awf-project/devcontainer-features`).

## Repository Structure

```
src/<feature>/
  devcontainer-feature.json   # Feature metadata (required)
  install.sh                  # Installation script (required)
  *.sh                        # Helper scripts (optional, e.g. link-claude-config.sh)
test/<feature>/
  test.sh                     # Main test assertions (required)
  scenarios.json              # Test scenario definitions (required)
  <scenario-name>.sh          # Per-scenario test scripts (required per scenario)
.github/workflows/
  linter.yml                  # ShellCheck on src/**/*.sh (severity: error)
  validate-metadata.yml       # Validates devcontainer-feature.json schema
  test-pr.yml                 # Auto-detects and tests only changed features
  release.yml                 # Publishes to GHCR on v* tags
test-local.sh                 # Local test runner (devcontainer CLI)
test-integration.sh           # Full integration test with container lifecycle
renovate.json                 # Automerge patch updates, group by manager
```

## Creating a New Feature

### Checklist

1. `src/<feature>/devcontainer-feature.json`
2. `src/<feature>/install.sh`
3. Optional helper scripts in `src/<feature>/`
4. `test/<feature>/test.sh`
5. `test/<feature>/scenarios.json`
6. `test/<feature>/<scenario-name>.sh` for each scenario
7. Run `./test-local.sh <feature>` locally
8. Update `README.md` with feature documentation
9. Submit PR (CI auto-detects new feature and runs tests)

### Updating an Existing Feature

1. Bump `version` in `devcontainer-feature.json`
2. Update `install.sh`
3. Update/add test scenarios if behavior changed
4. Run `./test-local.sh <feature>` locally
5. Submit PR (CI tests only the changed feature)
6. After merge, push `v*` tag to publish to GHCR

---

## devcontainer-feature.json

### Required Fields

```json
{
  "id": "<feature-name>",
  "version": "1.0.0",
  "name": "Human Readable Name",
  "description": "One-line description of what this feature installs."
}
```

### Optional Fields

| Field | Usage | Example |
|-------|-------|---------|
| `options` | User-configurable inputs | `"version": { "type": "string", "default": "latest" }` |
| `documentationURL` | Link to upstream docs | `"https://docs.example.com"` |
| `licenseURL` | Link to upstream license | `"https://github.com/org/repo/blob/main/LICENSE"` |
| `customizations` | IDE extensions/plugins | `{ "vscode": { "extensions": [...] }, "jetbrains": { "plugins": [...] } }` |
| `containerEnv` | Env vars set in container | `{ "TOOL_HOME": "/opt/tool", "PATH": "/opt/tool/bin:${PATH}" }` |
| `mounts` | Docker volumes/binds | `[{ "source": "vol-${devcontainerId}", "target": "/data", "type": "volume" }]` |
| `postStartCommand` | Run after container starts | `"/usr/local/bin/setup-script"` |
| `installsAfter` | Feature ordering | `["ghcr.io/devcontainers/features/common-utils"]` |

### Options Convention

- `version`: `{ "type": "string", "default": "latest" }` — always include if tool is versionable
- Boolean sub-features: `{ "type": "boolean", "default": false }` — for optional components
- Option names use camelCase in JSON, engine injects them as UPPERCASED env vars:
  - `version` -> `$VERSION`
  - `precacheWeb` -> `$PRECACHEWEB`
  - `grammarPhp` -> `$GRAMMARPHP`

---

## install.sh

### Template

```bash
#!/bin/bash
set -e

# --- Options injected by devcontainer feature engine ---
VERSION="${VERSION:-latest}"

echo "==> <Feature> feature: version=${VERSION}"

# 1. Ensure dependencies
if ! command -v curl &>/dev/null; then
    apt-get update -y
    apt-get install -y --no-install-recommends curl ca-certificates
    apt-get clean && rm -rf /var/lib/apt/lists/*
fi

# 2. Resolve version (if "latest")
if [ "$VERSION" = "latest" ]; then
    VERSION=$(curl -fsSL "https://api.github.com/repos/<org>/<repo>/releases/latest" \
        | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "==> Resolved latest version: ${VERSION}"
fi

# 3. Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)  ARCH_SUFFIX="amd64" ;;
    aarch64|arm64)  ARCH_SUFFIX="arm64" ;;
    *)
        echo "ERROR: unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# 4. Download and install
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

DOWNLOAD_URL="https://github.com/<org>/<repo>/releases/download/${VERSION}/<binary>-${ARCH_SUFFIX}.tar.gz"
echo "==> Downloading ${DOWNLOAD_URL}..."
curl -fsSL "$DOWNLOAD_URL" -o "${TMP_DIR}/archive.tar.gz"
tar -xzf "${TMP_DIR}/archive.tar.gz" -C "$TMP_DIR"

install -m 0755 "${TMP_DIR}/<binary>" /usr/local/bin/<binary>

echo "==> <Feature> $(<binary> --version) installed at $(command -v <binary>)"

# 5. Install helper scripts (if any)
# install -m 0755 ./helper-script.sh /usr/local/bin/helper-script

# 6. Set ownership for remote user (if needed)
# if [ -n "${_REMOTE_USER:-}" ] && [ "$_REMOTE_USER" != "root" ]; then
#     chown -R "$_REMOTE_USER:$_REMOTE_USER" /some/path
# fi

echo "==> <Feature> feature install complete"
```

### Conventions

- **Shebang**: `#!/bin/bash` + `set -e` (fail on error)
- **Progress output**: prefix with `==>` (e.g. `echo "==> Installing..."`)
- **Error output**: prefix with `ERROR:` and `exit 1`
- **Dependencies**: `apt-get update -y && apt-get install -y --no-install-recommends <pkg>`
- **Apt cleanup**: `apt-get clean && rm -rf /var/lib/apt/lists/*` after dependency installs (reduces layer size)
- **Architecture**: support `x86_64`/`amd64` and `aarch64`/`arm64`, reject others
- **Binary placement**: always `/usr/local/bin/` for global PATH access
- **Temp cleanup**: `trap 'rm -rf "$TMP_DIR"' EXIT`
- **Remote user**: use `${_REMOTE_USER:-}` (injected by devcontainer engine)
- **Helper scripts**: ship as `./script.sh` in feature dir, install to `/usr/local/bin/`
- **GitHub API rate limit**: anonymous limit is 60 req/hour — document fallback to pinned version

### Patterns in Existing Features

| Pattern | Used by | Description |
|---------|---------|-------------|
| Deferred install | awf-cli | Install a helper script, actual binary downloaded at runtime via `postCreateCommand` |
| Config persistence | claude-code | Docker volume mount + symlink script in `postStartCommand` |
| Post-start guidance | grepai | Quickstart banner displayed at container start |
| Grammar compilation | tree-sitter | Build optional sub-components from source |
| Multi-target download | rtk | Try multiple target triples until one succeeds |
| Channel resolution | flutter | Map channel names (stable/beta) to download URLs |

---

## test.sh

### Template

```bash
#!/bin/bash
set -e

# Devcontainer feature test — run by devcontainers/action in CI
# Verifies <Feature> is correctly installed and on PATH.

echo "==> Testing <Feature> feature..."

# Binary must be on PATH
if ! command -v <binary> &>/dev/null; then
    echo "FAIL: <binary> not found on PATH"
    exit 1
fi
echo "PASS: <binary> on PATH ($(command -v <binary>))"

# Version check must succeed
<BINARY>_VERSION=$(<binary> --version 2>&1)
if [ -z "$<BINARY>_VERSION" ]; then
    echo "FAIL: <binary> --version returned empty output"
    exit 1
fi
echo "PASS: <binary> --version => ${<BINARY>_VERSION}"

# Check environment variables (if feature sets any)
# if [ -z "$TOOL_HOME" ]; then
#     echo "FAIL: TOOL_HOME not set"
#     exit 1
# fi
# echo "PASS: TOOL_HOME=${TOOL_HOME}"

echo "==> All <Feature> feature tests passed"
```

### Conventions

- **Output**: `PASS: <description>` or `FAIL: <description>` then `exit 1`
- **Final line**: `echo "==> All <Feature> feature tests passed"`
- **Assertions**: binary on PATH, version output, env vars, feature-specific files
- **Idempotent**: tests must not modify the container state

---

## scenarios.json

### Template

```json
{
  "install_<feature>_latest": {
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
      "<feature>": {}
    }
  },
  "install_<feature>_specific_version": {
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
      "<feature>": {
        "version": "x.y.z"
      }
    }
  }
}
```

### Conventions

- **Image**: always `mcr.microsoft.com/devcontainers/base:ubuntu`
- **Scenario naming**: `install_<feature>_<variant>` (snake_case)
- **Minimum scenarios**: default install + version-pinned install
- **Additional scenarios**: one per boolean option or notable configuration
- **Features key**: use the feature `id` (not the full GHCR path)
- **External dependencies**: add them in the `features` object (e.g. `"ghcr.io/devcontainers/features/github-cli:1": {}`)

---

## Scenario Test Scripts

### Template

```bash
#!/bin/bash
set -e

# Scenario: <scenario_name>
# <Description of what this scenario validates>

source "$(dirname "$0")/test.sh"

# Additional scenario-specific assertions
# INSTALLED=$(<binary> --version 2>&1 | grep -oP '\d+\.\d+\.\d+')
# EXPECTED="x.y.z"
# if [ "$INSTALLED" != "$EXPECTED" ]; then
#     echo "FAIL: Expected version ${EXPECTED}, got ${INSTALLED}"
#     exit 1
# fi
# echo "PASS: Correct version ${EXPECTED} installed"
```

### Conventions

- File name must match the scenario key in `scenarios.json`
- Source `test.sh` first to run base assertions
- Add only scenario-specific checks after sourcing
- For minimal scenarios (no extra checks), the file can just source `test.sh`

---

## CI/CD Pipeline

### On Pull Request

1. **ShellCheck** (`linter.yml`): lints all `src/**/*.sh`, severity `error`
2. **Metadata validation** (`validate-metadata.yml`): validates `devcontainer-feature.json` against spec
3. **Feature tests** (`test-pr.yml`): detects changed features by diffing `src/<feature>/` and `test/<feature>/` against PR base, tests only those

### On Release

1. Push a `v*` tag (e.g. `v1.2.0`)
2. `release.yml` publishes all features to GHCR via `devcontainers/action@v1`
3. Documentation is auto-generated

### Renovate

- Automerges patch updates for `github-actions` and `devcontainers` managers
- Groups updates by manager type
- Major `github-actions` updates require dashboard approval
- Schedule: weekday evenings + weekend mornings (Europe/Paris)

---

## Local Testing

```bash
# Test a feature with all scenarios
./test-local.sh <feature>

# Test a specific scenario
./test-local.sh <feature> <scenario-name>

# Test without Docker cache
./test-local.sh --no-cache <feature>

# Test with a different base image
./test-local.sh --base-image mcr.microsoft.com/devcontainers/base:debian <feature>

# Full integration test (builds container, runs test.sh inside)
./test-integration.sh <feature>

# Keep container alive for debugging
./test-integration.sh <feature> --keep
```

**Prerequisites**: `npm install -g @devcontainers/cli` + Docker running

---

## Generation Constraints

BEFORE writing any file, determine:
1. Install method: `github-release` | `curl-installer` | `package-manager` | `uv-tool` | `pipx` | `cargo` | `npm-global` | `go-install`
2. Version pinning: supported? (verify upstream docs — do not assume)
3. Version check command: `--version` | `-V` | `version` | `--help` (verify upstream — do not assume)
4. User-scoped install? → if YES, identify redirect env vars from table below

### Rules

```
MUST   Identify install method BEFORE writing devcontainer-feature.json
MUST   Every option in feature.json → corresponding $VAR usage in install.sh
MUST   Every scenario in scenarios.json → achievable by install.sh
MUST   Each scenario key in scenarios.json → matching .sh file in test/<feature>/
MUST   Test /usr/local/bin/<binary>, not ~/.local/bin/
MUST   Verify version check command works upstream before using in test.sh
NEVER  Declare `version` option if tool cannot pin versions
NEVER  `install -m 0755` a managed wrapper (uv/pipx/cargo wrappers depend on venv)
NEVER  Write under $HOME (/root/) — /root/ is mode 700, inaccessible to _REMOTE_USER
NEVER  Symlink from /root/ to /usr/local/bin/ — shebang still resolves through /root/
IF     install method is user-scoped → export redirect env vars BEFORE install command
IF     version pinning impossible → only create install_<feature>_latest scenario
IF     --version unsupported → use verified alternative in test.sh
AFTER  redirect install → chmod -R a+rX /usr/local/share/<tool>/
IGNORE InvalidDefaultArgInFrom: ARG $BASE_IMAGE (harmless Docker warning)
```

### Permission Redirect Table

When install method writes under `$HOME`, redirect ALL paths to `/usr/local/`:

| Tool | Redirect env vars |
|------|-------------------|
| `uv tool install` | `UV_TOOL_BIN_DIR=/usr/local/bin` `UV_TOOL_DIR=/usr/local/share/uv/tools` `UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python` |
| `pipx install` | `PIPX_HOME=/usr/local/share/pipx` `PIPX_BIN_DIR=/usr/local/bin` |
| `cargo install` | `CARGO_HOME=/usr/local/share/cargo` |
| `npm install -g` | `npm config set prefix /usr/local` |
| `go install` | `GOPATH=/usr/local/share/go` `GOBIN=/usr/local/bin` |
| `curl \| sh` | varies — check tool docs for redirect options |

---

## Language and Style

- All code, comments, commit messages, and documentation in **English**
- Shell scripts follow ShellCheck rules (no SC errors)
- Commit convention: `feat(<feature>): <description>` / `fix(<feature>): <description>`
