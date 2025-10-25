# Package Update Automation

This repository automatically updates package manifests when tools publish new releases.

## How It Works

### 1. Tool Repository Triggers Update

When a tool (e.g., `quickctx`) publishes a release, it sends a webhook to this repository:

```yaml
# In tool repo: .github/workflows/update-package-managers.yml
- name: Trigger package repository update
  run: |
    curl -X POST \
      https://api.github.com/repos/CaddyGlow/homebrew-packages/dispatches \
      -d '{
        "event_type": "update-package",
        "client_payload": {
          "tool": "quickctx",
          "version": "0.2.0",
          "repository": "CaddyGlow/quickctx"
        }
      }'
```

### 2. This Repository Receives and Processes

The workflow in `.github/workflows/update-package.yml`:

1. Downloads release artifacts
2. Calculates SHA256 hashes
3. Updates `Formula/{tool}.rb` (Homebrew)
4. Updates `bucket/{tool}.json` (Scoop)
5. Commits and pushes changes

### 3. Users Get Updates

Users with the tap/bucket added automatically get the new version:

```bash
brew update && brew upgrade quickctx
scoop update && scoop update quickctx
```

## No PAT Token Needed!

**Key benefit:** Tool repositories don't need Personal Access Tokens.

- Tool repos only need `GITHUB_TOKEN` (automatic)
- This repo handles all the updates
- Cleaner security model

## Adding a New Tool

### In Your Tool Repository

Add this workflow (`.github/workflows/update-package-managers.yml`):

```yaml
name: Update Package Managers

on:
  release:
    types: [published]

permissions:
  contents: read

jobs:
  notify-package-repo:
    runs-on: ubuntu-latest
    steps:
      - name: Get version
        id: version
        run: |
          VERSION="${{ github.event.release.tag_name }}"
          echo "VERSION=${VERSION#v}" >> $GITHUB_OUTPUT

      - name: Trigger package repository update
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            https://api.github.com/repos/CaddyGlow/homebrew-packages/dispatches \
            -d '{
              "event_type": "update-package",
              "client_payload": {
                "tool": "YOUR_TOOL_NAME",
                "version": "${{ steps.version.outputs.VERSION }}",
                "repository": "${{ github.repository }}"
              }
            }'
```

Replace `YOUR_TOOL_NAME` with your tool's binary name.

### Expected Release Artifacts

Your tool should publish these artifacts:

**For Homebrew:**
- `{tool}-x86_64-apple-darwin.tar.gz` (macOS Intel)
- `{tool}-aarch64-apple-darwin.tar.gz` (macOS Apple Silicon)
- `{tool}-x86_64-unknown-linux-gnu.tar.gz` (Linux x64)
- `{tool}-aarch64-unknown-linux-gnu.tar.gz` (Linux ARM64)

**For Scoop:**
- `{tool}-x86_64-pc-windows-msvc.zip` (Windows x64)
- `{tool}-i686-pc-windows-msvc.zip` (Windows x86)

Archives should contain the binary at the root level.

## Manual Testing

Trigger update manually:

```bash
# Via GitHub UI
# Go to: https://github.com/CaddyGlow/homebrew-packages/actions
# Select "Update Package" workflow
# Click "Run workflow"
# Fill in:
#   - tool: quickctx
#   - version: 0.1.1
#   - repository: CaddyGlow/quickctx

# Or via gh CLI
gh workflow run update-package.yml \
  -f tool=quickctx \
  -f version=0.1.1 \
  -f repository=CaddyGlow/quickctx
```

## Troubleshooting

### Webhook Not Triggering

Check that the tool repository has public access or the `GITHUB_TOKEN` has the right permissions.

### Artifacts Not Found

Verify that:
1. Release artifacts use the expected naming pattern
2. Release is published (not draft)
3. Artifacts are attached to the release

### Hash Mismatch

The workflow automatically calculates fresh hashes. If users report hash mismatches:
1. Re-run the workflow
2. Check that artifacts weren't modified after release

## Security

- Tool repos use default `GITHUB_TOKEN` (read-only)
- This repo has write access to itself
- No cross-repo secrets needed
- Clean separation of concerns
