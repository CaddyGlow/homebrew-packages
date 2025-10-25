# Release Scripts

Automation scripts for managing releases across CaddyGlow Rust projects.

## release.sh

Comprehensive release management script that handles versioning, git operations, and GitHub releases.

### Features

- ✅ **Pre-flight checks** - Verifies all prerequisites (gh, cargo, jq)
- ✅ **Dirty tree handling** - Interactive prompts for uncommitted changes
- ✅ **Version verification** - Compares Cargo.toml, git tags, and GitHub releases
- ✅ **Auto-increment** - Automatically bumps patch version if not specified
- ✅ **Safe releases** - Creates commits, tags, and GitHub releases
- ✅ **Force mode** - Allows overriding existing releases (with warnings)

### Prerequisites

```bash
# Install required tools
sudo apt install jq  # JSON parser

# Install GitHub CLI
# See: https://cli.github.com/

# Authenticate with GitHub
gh auth login
```

### Usage

#### Normal Release (Auto-increment)

```bash
# Automatically increment patch version (e.g., 0.1.1 → 0.1.2)
./scripts/release.sh ~/projects/quickctx
```

**What it does:**
1. Checks for uncommitted changes (prompts if found)
2. Verifies Cargo.toml, git tag, and GitHub release versions
3. Increments patch version
4. Updates Cargo.toml and Cargo.lock
5. Creates commit: `chore(release): bump version to X.X.X`
6. Pushes branch
7. Creates and pushes git tag `vX.X.X`
8. Creates GitHub release (triggers CI/CD)

#### Normal Release (Specific Version)

```bash
# Release specific version
./scripts/release.sh ~/projects/quickctx 0.2.0
```

#### Force Re-release (Same Version)

```bash
# Override existing release with current version
./scripts/release.sh ~/projects/quickctx --force
```

**⚠️ WARNING:** This is destructive and will:
- Delete the GitHub release
- Delete and recreate the git tag
- Force push the tag

Use cases:
- CI/CD failed and you need to retry
- Assets were corrupted
- Emergency hotfix to existing release

#### Force Re-release (Different Version)

```bash
# Override and change version
./scripts/release.sh ~/projects/quickctx 0.1.1 --force
```

### Interactive Features

#### Dirty Working Tree Handling

If the script detects uncommitted changes, it will show `git status` and prompt:

```
What would you like to do?
  1) Stage all and commit (git add -A && git commit)
  2) Drop to interactive shell
  3) Ignore and continue (NOT RECOMMENDED)
  4) Abort
```

**Option 1: Stage and commit**
- Runs `git add -A`
- Prompts for commit message
- Commits changes

**Option 2: Interactive shell**
- Drops you into a bash shell
- Lets you manually fix issues
- Re-checks when you `exit`

**Option 3: Ignore**
- Continues with dirty tree (dangerous!)
- Only use if you know what you're doing

**Option 4: Abort**
- Safely exits the script

### Version Verification

The script checks three sources:

1. **Cargo.toml** - The source of truth
2. **Git tags** - Latest tag in repository
3. **GitHub releases** - Latest release on GitHub

Example output:

```
ℹ Version status:
  Cargo.toml:       0.1.1
  Latest git tag:   0.1.1
  Latest GH release: 0.1.1
```

If versions don't match, warnings are displayed.

### Workflow Integration

The script works seamlessly with the reusable CI/CD workflows:

1. Script creates git tag (e.g., `v0.1.2`)
2. Tag push triggers CI workflow
3. CI workflow:
   - Runs tests
   - Builds binaries for all platforms
   - Creates GitHub release with artifacts
4. Release triggers package manager update workflow
5. Package manager workflow updates Homebrew/Scoop formulas

### Examples

#### Example 1: First Time Release

```bash
$ ./scripts/release.sh ~/projects/shelltape

ℹ Running pre-flight checks...
✓ All prerequisites satisfied
ℹ Checking project directory: /home/user/projects/shelltape
✓ Project directory is valid
ℹ Checking working tree status...
✓ Working tree is clean
ℹ Version status:
  Cargo.toml:       0.1.0
  Latest git tag:   <none>
  Latest GH release: <none>

ℹ Auto-incrementing version: 0.1.0 → 0.1.1
ℹ Release Summary:
  Project: /home/user/projects/shelltape
  Current version: 0.1.0
  New version: 0.1.1

? Proceed with release? [y/N]: y
ℹ Updating Cargo.toml to version 0.1.1...
✓ Updated Cargo.toml and Cargo.lock
ℹ Creating release commit...
✓ Created release commit
ℹ Pushing branch...
✓ Branch pushed
ℹ Creating and pushing tag: v0.1.1...
✓ Tag created and pushed
ℹ Creating GitHub release: v0.1.1...
✓ GitHub release created: v0.1.1
ℹ CI/CD workflows will now build and publish artifacts

✓ Release 0.1.1 completed successfully!
ℹ Monitor CI/CD at: https://github.com/CaddyGlow/shelltape/actions
```

#### Example 2: Dirty Working Tree

```bash
$ ./scripts/release.sh ~/projects/quickctx

ℹ Running pre-flight checks...
✓ All prerequisites satisfied
ℹ Checking project directory: /home/user/projects/quickctx
✓ Project directory is valid
ℹ Checking working tree status...
⚠ Working tree has uncommitted changes:

 M src/main.rs
?? debug.log

What would you like to do?
  1) Stage all and commit (git add -A && git commit)
  2) Drop to interactive shell
  3) Ignore and continue (NOT RECOMMENDED)
  4) Abort

? Choose [1-4]: 1
? Commit message: fix: correct debug output formatting
✓ Changes committed
✓ Working tree is clean
...
```

#### Example 3: Force Re-release

```bash
$ ./scripts/release.sh ~/projects/ghdl --force

ℹ Running pre-flight checks...
✓ All prerequisites satisfied
ℹ Checking project directory: /home/user/projects/ghdl
✓ Project directory is valid
ℹ Checking working tree status...
✓ Working tree is clean
ℹ Version status:
  Cargo.toml:       0.1.1
  Latest git tag:   0.1.1
  Latest GH release: 0.1.1

⚠ Force mode with current version: 0.1.1

✗ ⚠️  FORCE MODE - DESTRUCTIVE OPERATION ⚠️

This will:
  1. Delete GitHub release v0.1.1
  2. Delete and recreate git tag v0.1.1
  3. Force push tag
  4. Create new GitHub release

⚠ This operation is DANGEROUS and will rewrite history!

? Are you ABSOLUTELY sure? [y/N]: y
ℹ Deleting existing GitHub release: v0.1.1...
✓ Deleted GitHub release: v0.1.1
ℹ Deleting and recreating tag: v0.1.1...
✓ Deleted local tag: v0.1.1
✓ Deleted remote tag: v0.1.1
✓ Recreated and force-pushed tag: v0.1.1
ℹ Creating GitHub release: v0.1.1...
✓ GitHub release created: v0.1.1
ℹ CI/CD workflows will now build and publish artifacts

✓ Force release 0.1.1 completed!
⚠ Remember: This rewrote git history. Collaborators may need to sync.
```

### Troubleshooting

#### Error: "GitHub CLI is not authenticated"

```bash
gh auth login
```

#### Error: "jq is not installed"

```bash
sudo apt install jq
```

#### Error: "Could not parse version from Cargo.toml"

Ensure your Cargo.toml has a version field:
```toml
[package]
version = "0.1.0"
```

#### Error: "Not a git repository"

Initialize git:
```bash
cd /path/to/project
git init
git remote add origin git@github.com:CaddyGlow/project.git
```

### Best Practices

1. **Always review changes** before confirming release
2. **Use normal mode** for regular releases
3. **Reserve force mode** for emergencies only
4. **Commit your work** before running the script
5. **Monitor CI/CD** after release to ensure builds succeed

### Safety Features

- ✅ Checks for uncommitted changes before proceeding
- ✅ Requires explicit confirmation for releases
- ✅ Double confirmation for force mode
- ✅ Shows version diff before making changes
- ✅ Verifies prerequisites before starting
- ✅ Provides clear error messages

### Integration with Package Managers

After the script creates a GitHub release:

1. **CI/CD builds** all platform binaries
2. **GitHub release** is populated with artifacts
3. **Package manager workflow** is triggered (if configured)
4. **Homebrew/Scoop** formulas are automatically updated

You can then verify:
```bash
# Check Homebrew formula
brew install CaddyGlow/packages/quickctx

# Check Scoop manifest
scoop install quickctx
```
