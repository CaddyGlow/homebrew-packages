# Reusable GitHub Actions Workflows

This directory contains reusable workflows for Rust-based tools in the CaddyGlow organization.

## Available Workflows

### 1. `rust-ci.yml` - Complete Rust CI/CD Pipeline

A comprehensive workflow that handles testing, cross-platform building, and releasing for Rust projects.

**Features:**
- Automated testing with `cargo test`
- Code quality checks (rustfmt, clippy)
- Cross-platform builds for 14+ targets (Linux, Windows, macOS, Android)
- Automated GitHub releases
- Support for multiple binaries per project
- Asset packaging (README, configs, etc.)

**Usage:**

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ "main" ]
    tags: [ "v*" ]
  pull_request:
  workflow_dispatch:
    inputs:
      force_release:
        description: 'Force a release (even without a tag)'
        required: false
        type: boolean
        default: false

permissions:
  contents: write

jobs:
  ci:
    uses: CaddyGlow/homebrew-packages/.github/workflows/rust-ci.yml@main
    with:
      binaries: '["my-tool"]'
      assets: '["README.md", "config/**"]'
      force_release: ${{ github.event.inputs.force_release == 'true' }}
```

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `binaries` | Yes | - | JSON array of binary names, e.g., `["tool"]` or `["server", "client"]` |
| `assets` | No | `[]` | JSON array of asset paths to include in archives |
| `targets` | No | (comprehensive list) | JSON array of target triples to build |
| `skip_tests` | No | `false` | Skip running tests |
| `test_command` | No | `cargo test --all-features` | Custom test command |
| `clippy_args` | No | `--all-targets --all-features` | Additional clippy arguments |
| `skip_release_on_tags` | No | `false` | Skip automatic release when tags are pushed |
| `force_release` | No | `false` | Force a release even without a tag |

**Default Target Platforms:**

- **Linux (GNU):** x86_64, aarch64, armv7, i686
- **Linux (musl):** x86_64, aarch64, armv7
- **Windows:** x86_64 (MSVC & GNU), i686 (MSVC)
- **macOS:** x86_64, aarch64 (Apple Silicon)
- **Android:** aarch64, armv7

**Examples:**

Single binary with assets:
```yaml
with:
  binaries: '["quickctx"]'
  assets: '["README.md", "LICENSE"]'
```

Multiple binaries:
```yaml
with:
  binaries: '["server", "client", "admin"]'
  assets: '["config/**", "README.md"]'
```

Custom targets only:
```yaml
with:
  binaries: '["my-tool"]'
  targets: '[
    {"target": "x86_64-unknown-linux-gnu", "runs_on": "ubuntu-latest", "archive": "tar.gz", "exe_suffix": ""},
    {"target": "x86_64-apple-darwin", "runs_on": "macos-latest", "archive": "tar.gz", "exe_suffix": ""}
  ]'
```

### 2. `notify-package-managers.yml` - Package Manager Update Notification

Triggers updates in the homebrew-packages repository when a new release is published.

**Usage:**

```yaml
# .github/workflows/update-package-managers.yml
name: Update Package Managers

on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to update (e.g., 0.1.1)'
        required: false
        type: string

permissions:
  contents: read

jobs:
  notify:
    uses: CaddyGlow/homebrew-packages/.github/workflows/notify-package-managers.yml@main
    with:
      tool_name: my-tool
      version: ${{ github.event.inputs.version }}
    secrets:
      APP_ID: ${{ secrets.APP_ID }}
      APP_PRIVATE_KEY: ${{ secrets.APP_PRIVATE_KEY }}
```

**Inputs:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `tool_name` | Yes | - | Name of the tool (e.g., `quickctx`, `shelltape`) |
| `version` | No | (from release tag) | Version to update |

**Required Secrets:**

- `APP_ID`: GitHub App ID for authentication
- `APP_PRIVATE_KEY`: GitHub App private key for authentication

## Workflow Behavior

### CI Workflow

1. **On Pull Requests:** Runs tests and checks only
2. **On Push to Main:** Runs tests, checks, and quick build validation
3. **On Tags (v*):** Full CI/CD - tests, cross-platform builds, and GitHub release
4. **On Manual Dispatch:** Can force a release without a tag

### Package Manager Notification

1. **On Release Published:** Automatically notifies homebrew-packages
2. **On Manual Dispatch:** Manually trigger update for a specific version

## Setting Up a New Tool

1. Create `.github/workflows/ci.yml` in your tool repository (see examples above)
2. (Optional) Create `.github/workflows/update-package-managers.yml` if you want package manager integration
3. Ensure your repository has the required secrets configured (for package manager notifications)
4. Push a tag like `v0.1.0` to trigger a release

## Archive Naming Convention

Archives are named as: `{primary-binary}-{target}.{tar.gz|zip}`

For example:
- `quickctx-x86_64-unknown-linux-gnu.tar.gz`
- `shelltape-x86_64-pc-windows-msvc.zip`
- `my-tool-aarch64-apple-darwin.tar.gz`

## Troubleshooting

### Tests failing?
Use `skip_tests: true` or customize with `test_command: 'cargo test --lib'`

### Need different clippy settings?
Set `clippy_args: '--all-targets --all-features -- -D warnings'`

### Want to skip releases on tags?
Use `skip_release_on_tags: true` if you handle releases separately

### Need to build for fewer targets?
Provide a custom `targets` JSON array with only the platforms you need
