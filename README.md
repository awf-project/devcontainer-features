# Dev Container Features

A collection of [Dev Container Features](https://containers.dev/implementors/features/) published to GitHub Container Registry (GHCR).

## Table of Contents

- [Available Features](#available-features)
  - [Flutter SDK](#flutter-sdk)
  - [Claude Code](#claude-code)
  - [Tree-sitter](#tree-sitter)
  - [RTK](#rtk)
  - [AWF CLI](#awf-cli)
- [Repository Structure](#repository-structure)
- [Local Testing](#local-testing)
- [Contributing](#contributing)
- [Publishing](#publishing)
- [License](#license)

## Available Features

### Flutter SDK

Installs the Flutter SDK with Dart for cross-platform development. Supports stable, beta, master channels and specific versions.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/flutter:1": {}
  }
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `stable` | Flutter channel (`stable`, `beta`, `master`) or specific version (e.g. `3.27.4`) |
| `precacheWeb` | boolean | `false` | Run `flutter precache --web` after install |
| `precacheLinux` | boolean | `false` | Run `flutter precache --linux` after install |
| `precacheAndroid` | boolean | `false` | Run `flutter precache --android` after install (requires Android SDK) |

#### Examples

Pin a specific Flutter version:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/flutter:1": {
      "version": "3.27.4"
    }
  }
}
```

Install with web precache for faster first build:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/flutter:1": {
      "precacheWeb": true
    }
  }
}
```

#### Environment

| Variable | Value |
|----------|-------|
| `FLUTTER_HOME` | `/opt/flutter` |

Flutter and Dart binaries are added to `PATH` automatically.

### Claude Code

Installs [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's official CLI for Claude via the official installer. Supports latest and pinned versions.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/claude-code:1": {}
  }
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version to install: `latest` or a specific version (e.g. `1.0.3`) |

#### Examples

Pin a specific version:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/claude-code:1": {
      "version": "1.0.3"
    }
  }
}
```

#### API Key

The feature does not set `ANTHROPIC_API_KEY` automatically. Pass it from your host via `remoteEnv` in your `devcontainer.json`:

```jsonc
{
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

This injects the key at runtime without baking it into the Docker image layer.

#### Persistent Configuration

Configuration persists automatically via a Docker named volume mounted at `/claude-config`. On each container start, a symlink `~/.claude -> /claude-config` is created for the logged-in user.

- No configuration required — it works out of the box
- Authentication and settings survive container rebuilds
- Each devcontainer gets its own isolated volume (`claude-code-config-<devcontainerId>`)

No additional features required — Claude Code is installed as a standalone binary.

### Tree-sitter

Installs the [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) CLI for incremental parsing. Optionally compiles grammars (PHP, TypeScript, JavaScript, Go, Dart, Python, YAML) from official repos.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/tree-sitter:1": {}
  }
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Tree-sitter CLI version: `latest` or a specific version (e.g. `0.25.4`) |
| `grammarPhp` | boolean | `false` | Compile and install the PHP grammar |
| `grammarTypescript` | boolean | `false` | Compile and install the TypeScript grammar |
| `grammarJavascript` | boolean | `false` | Compile and install the JavaScript grammar |
| `grammarGo` | boolean | `false` | Compile and install the Go grammar |
| `grammarDart` | boolean | `false` | Compile and install the Dart grammar |
| `grammarPython` | boolean | `false` | Compile and install the Python grammar |
| `grammarYaml` | boolean | `false` | Compile and install the YAML grammar |

#### Examples

Install with PHP and TypeScript grammars:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/tree-sitter:1": {
      "grammarPhp": true,
      "grammarTypescript": true
    }
  }
}
```

Pin a specific version with all grammars:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/tree-sitter:1": {
      "version": "0.25.4",
      "grammarPhp": true,
      "grammarTypescript": true,
      "grammarJavascript": true,
      "grammarGo": true,
      "grammarDart": true,
      "grammarPython": true,
      "grammarYaml": true
    }
  }
}
```

#### Environment

| Variable | Value |
|----------|-------|
| `TREE_SITTER_DIR` | `/usr/local/lib/tree-sitter` |

Tree-sitter CLI is added to `PATH` automatically. Compiled grammars are stored under `$TREE_SITTER_DIR`.

### RTK

Installs [RTK](https://www.rtk-ai.app/), a token-optimized CLI proxy for AI coding agents. Reduces token usage by 60-90% on dev operations by filtering and compressing tool output.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/rtk:1": {}
  }
}
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `version` | string | `latest` | Version to install: `latest` or a specific version (e.g. `0.5.0`) |

#### Examples

Pin a specific version:

```jsonc
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/rtk:1": {
      "version": "0.5.0"
    }
  }
}
```

#### Architecture Support

RTK supports Linux containers on both `x86_64` (amd64) and `aarch64` (arm64) architectures. The feature automatically detects the container architecture and downloads the appropriate binary.

#### Global Initialization

The feature runs `rtk init --global` during installation, setting up the global configuration for the container user.

### AWF CLI

> **Private package** — This feature requires access to the [awf-project/cli](https://github.com/awf-project/cli) private repository via the `gh` CLI. Only the latest version is available (active development).

Installs [AWF CLI](https://github.com/awf-project/cli), an AI Workflow CLI for orchestrating AI coding agents.

Since the repository is private, the binary is downloaded at container startup (not during build) using `gh release download`. This requires the `gh` CLI feature and your host `gh` config mounted into the container.

```jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/awf-project/devcontainer-features/awf-cli:1": {}
  },
  "mounts": [
    "source=${localEnv:HOME}/.config/gh,target=/home/vscode/.config/gh,type=bind,readonly"
  ],
  "postCreateCommand": "awf-install"
}
```

#### How it works

1. **Build time** (`install.sh`): installs dependencies and places the `awf-install` helper script
2. **Container start** (`postCreateCommand`): `awf-install` uses `gh release download` to fetch the latest binary from the private repo
3. Subsequent rebuilds skip the download if `awf` is already installed

#### Architecture Support

AWF CLI supports Linux containers on both `x86_64` (amd64) and `aarch64` (arm64) architectures. The feature automatically detects the container architecture and downloads the appropriate binary.

---

## Repository Structure

```
src/
  claude-code/          # Claude Code feature
    devcontainer-feature.json
    install.sh
  flutter/              # Flutter SDK feature
    devcontainer-feature.json
    install.sh
  grepai/               # GrepAI feature
    devcontainer-feature.json
    install.sh
  awf-cli/              # AWF CLI feature (private)
    devcontainer-feature.json
    install.sh
  rtk/                  # RTK feature
    devcontainer-feature.json
    install.sh
  tree-sitter/          # Tree-sitter feature
    devcontainer-feature.json
    install.sh
test/
  claude-code/          # Claude Code tests
    scenarios.json
    test.sh
  flutter/              # Flutter tests
    scenarios.json
    test.sh
  grepai/               # GrepAI tests
    scenarios.json
    test.sh
  awf-cli/              # AWF CLI tests
    scenarios.json
    test.sh
  rtk/                  # RTK tests
    scenarios.json
    test.sh
  tree-sitter/          # Tree-sitter tests
    scenarios.json
    test.sh
.github/
  workflows/
    release.yml         # CI/CD: test on PR, publish on tag
```

## Local Testing

Test features locally before pushing:

```bash
# All scenarios
./test-local.sh

# Specific feature
./test-local.sh flutter

# Specific scenario
./test-local.sh flutter install_flutter_stable

# Force rebuild without Docker cache
./test-local.sh --no-cache claude-code
```

Requires Docker and the [Dev Container CLI](https://github.com/devcontainers/cli) (`npm install -g @devcontainers/cli`).

## Contributing

1. Fork and clone the repository
2. Create a feature branch
3. Add or modify features under `src/`
4. Add matching tests under `test/`
5. Run `./test-local.sh <feature>` to validate locally
6. Open a pull request against `main`

Tests run automatically on pull requests via [devcontainers/action](https://github.com/devcontainers/action).

## Publishing

Features are published to GHCR when a version tag is pushed:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## License

[MIT](LICENSE)
