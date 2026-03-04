# Update README.md

Add documentation for a new devcontainer feature: **{{.inputs.description}}**

Feature ID: `{{trimSpace .states.validate_name.Output}}`

## Steps

1. Read `README.md` to understand the documentation pattern
2. Read `src/{{trimSpace .states.validate_name.Output}}/devcontainer-feature.json`
3. Read `src/{{trimSpace .states.validate_name.Output}}/install.sh`

## Changes

### 1. Table of Contents

Insert in `Available Features`, alphabetical by feature name:
```markdown
- [<Feature Name>](#{{trimSpace .states.validate_name.Output}})
```
(Derive the human-readable feature name by capitalizing each hyphen-separated word of the ID)

### 2. Feature Section

Insert a `### <Feature Name>` section in alphabetical order. Structure:

1. One-line description from `devcontainer-feature.json`
2. Default `devcontainer.json` usage snippet
3. `#### Options` table — **omit if no options defined**
4. `#### Examples` — always include a version-pinning example; add more for non-trivial option combinations
5. `#### Environment` — add only if the feature sets env vars or modifies `PATH`
6. Feature-specific subsections — add only for notable behaviors (e.g., persistent config, API key setup)

Template for steps 1-3:

```markdown
### <Feature Name>

<one-line description>

\`\`\`jsonc
// devcontainer.json
{
  "features": {
    "ghcr.io/awf-project/devcontainer-features/{{trimSpace .states.validate_name.Output}}:1": {}
  }
}
\`\`\`

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| ... |
```

## Rules

- Use `Edit`, not `Write` — this is an existing file
- Use `Read` to inspect the file before editing
- Do not use `Bash`
- Do not modify existing content
- Both TOC entry and section go in alphabetical order by feature name
- Omit `#### Options` if `devcontainer-feature.json` has no options
- Omit `#### Examples` if the feature has only a `version` option and the pattern is self-evident from the options table
