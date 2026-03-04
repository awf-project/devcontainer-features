# Generate install.sh

Create the installation script for: **{{.inputs.description}}**

## Instructions

1. Read `CLAUDE.md` section "install.sh Template" for the base template.
2. Read `src/{{trimSpace .states.validate_name.Output}}/devcontainer-feature.json` (already generated).
3. Read the closest reference script and follow its pattern:
   - `src/rtk/install.sh` — multi-target binary (try multiple target triples)
   - `src/claude-code/install.sh` — config persistence (volume mount + symlink helper)
   - `src/tree-sitter/install.sh` — post-install compilation from source
   - Use the CLAUDE.md template directly for a standard single-binary install
4. Create `src/{{trimSpace .states.validate_name.Output}}/install.sh` (and any helper scripts the metadata requires).

## Script Structure Order

1. Options from env vars (`VERSION="${VERSION:-latest}"`)
2. Dependency check (`apt-get update && install && clean`)
3. Version resolution (GitHub API if "latest")
4. Architecture detection (`x86_64`/`amd64`, `aarch64`/`arm64`, reject others)
5. Download and install to `/usr/local/bin/`
6. Helper scripts / post-install config (if any)
7. Verification and `==> <Feature> feature install complete` message

## ShellCheck Requirements

- Quote all variable expansions: `"${VAR}"` not `$VAR`
- Use `|| true` on non-critical commands that may return non-zero
- Use `[ ]` not `[[ ]]`
- After `apt-get install`, always add: `apt-get clean && rm -rf /var/lib/apt/lists/*`
- Temp cleanup: `trap 'rm -rf "$TMP_DIR"' EXIT`

## Constraints

- Write only files under `src/{{trimSpace .states.validate_name.Output}}/`
- Do not modify any other existing files
- Do not use Bash to test the script — ShellCheck runs as a separate pipeline step
- All scripts must pass ShellCheck severity `error`
