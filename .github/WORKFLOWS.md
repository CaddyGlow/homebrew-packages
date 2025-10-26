# GitHub Workflows Documentation

This repository uses multiple GitHub Actions workflows to automate package generation and updates across different package managers.

## Workflows Overview

### 1. `update-package.yml` - Homebrew & Scoop Updates

**Purpose:** Updates Homebrew (macOS/Linux) and Scoop (Windows) packages when triggered.

**Triggers:**
- `repository_dispatch` with type `update-package`
- Manual `workflow_dispatch`

**What it does:**
1. Downloads and hashes release artifacts for:
   - macOS (x86_64 and ARM64)
   - Linux (x86_64 and ARM64)
   - Windows (x64 and x86)
2. Updates `Formula/{tool}.rb` (Homebrew formula)
3. Updates `scoop/{tool}.json` (Scoop manifest)
4. Commits and pushes changes
5. Triggers the APK package generation workflow

**Required artifacts:**
- `{tool}-x86_64-apple-darwin.tar.gz`
- `{tool}-aarch64-apple-darwin.tar.gz`
- `{tool}-x86_64-unknown-linux-gnu.tar.gz`
- `{tool}-aarch64-unknown-linux-gnu.tar.gz`
- `{tool}-x86_64-pc-windows-msvc.zip`
- `{tool}-i686-pc-windows-msvc.zip`

---

### 2. `generate-apk-packages.yml` - Alpine & Termux Package Generation

**Purpose:** Generates Alpine Linux and Termux (Android) packages independently.

**Triggers:**
- `repository_dispatch` with type `generate-apk`
- Manual `workflow_dispatch`
- Automatically triggered by `update-package.yml`

**What it does:**
1. Downloads and hashes release artifacts for:
   - Linux musl (x86_64 and ARM64) for Alpine
   - Android ARM64 for Termux
2. Detects binaries from Homebrew formula
3. Generates `alpine/APKBUILD.{tool}` with SHA512 checksums
4. Generates `termux/build.sh.{tool}` with SHA256 checksums
5. Commits and pushes changes

**Required artifacts:**
- `{tool}-x86_64-unknown-linux-musl.tar.gz` (Alpine x64)
- `{tool}-aarch64-unknown-linux-musl.tar.gz` (Alpine ARM64)
- `{tool}-aarch64-linux-android.tar.gz` (Termux)

**Graceful handling:**
- If musl artifacts are missing, Alpine package generation is skipped
- If Android artifacts are missing, Termux package generation is skipped
- The workflow succeeds even if some artifacts are unavailable

---

### 3. `notify-package-managers.yml` - Automated Triggering

**Purpose:** Automatically triggers package updates when a new release is created in tool repositories.

**Triggers:**
- `repository_dispatch` from tool repositories
- Triggered when a new GitHub release is published

**What it does:**
1. Receives release information from tool repository
2. Triggers `update-package.yml` workflow
3. (Update-package.yml then triggers `generate-apk-packages.yml`)

---

## Workflow Execution Flow

```
Tool Release Published
       ↓
notify-package-managers.yml
       ↓
update-package.yml
  ├─→ Updates Homebrew
  ├─→ Updates Scoop
  └─→ Triggers generate-apk-packages.yml
           ↓
      generate-apk-packages.yml
        ├─→ Generates Alpine APKBUILD
        └─→ Generates Termux build.sh
```

## Manual Usage

### Update All Packages
```bash
# From tool repository after creating a release
gh workflow run update-package.yml \
  -f tool="quickctx" \
  -f version="0.1.2" \
  -f repository="CaddyGlow/quickctx"
```

### Generate Only APK Packages
```bash
# Useful if you only want to regenerate Alpine/Termux packages
gh workflow run generate-apk-packages.yml \
  -f tool="quickctx" \
  -f version="0.1.2" \
  -f repository="CaddyGlow/quickctx"
```

## Adding New Tools

When adding a new tool to this repository:

1. Ensure the tool's CI/CD pipeline builds all required artifacts
2. Trigger the update-package workflow with the tool name and version
3. The workflows will automatically create all package files

## Build Targets Required

For full package support, your Rust projects should build these targets:

**Homebrew/Scoop (glibc-based):**
- `x86_64-apple-darwin` (macOS Intel)
- `aarch64-apple-darwin` (macOS ARM)
- `x86_64-unknown-linux-gnu` (Linux x64)
- `aarch64-unknown-linux-gnu` (Linux ARM64)
- `x86_64-pc-windows-msvc` (Windows x64)
- `i686-pc-windows-msvc` (Windows x86)

**Alpine Linux (musl-based):**
- `x86_64-unknown-linux-musl` (Alpine x64)
- `aarch64-unknown-linux-musl` (Alpine ARM64)

**Termux (Android):**
- `aarch64-linux-android` (Android ARM64)

## Troubleshooting

### Workflow fails due to missing artifacts
- Check that the release version exists
- Verify all required artifacts are attached to the release
- For APK packages, missing artifacts will result in skipped generation (not failure)

### Homebrew/Scoop packages not updating
- Ensure `update-package.yml` completed successfully
- Check that the artifacts are accessible and downloadable

### Alpine/Termux packages not generating
- Check `generate-apk-packages.yml` workflow logs
- Verify musl and Android artifacts are available in the release
- The workflow will skip generation if artifacts are missing
