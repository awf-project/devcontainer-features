# Dev Container Features

A collection of [Dev Container Features](https://containers.dev/implementors/features/) published to GitHub Container Registry (GHCR).

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

## Repository Structure

```
src/
  flutter/              # Flutter feature source
    devcontainer-feature.json
    install.sh
test/
  flutter/              # Flutter feature tests
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
