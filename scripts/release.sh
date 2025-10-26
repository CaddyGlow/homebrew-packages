#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_NAME="$(basename "$0")"
FORCE_MODE=false
UPDATE_PACKAGES_ONLY=false
NEW_VERSION=""
PROJECT_PATH=""

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

die() {
    error "$*"
    exit 1
}

confirm() {
    local prompt="$1"
    local response
    read -r -p "$(echo -e "${YELLOW}?${NC} $prompt [y/N]: ")" response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME <project-path> [version] [--force|--update-packages]

Release management script for Rust projects.

Arguments:
  project-path       Path to the Rust project directory
  version            Optional: specific version (e.g., 0.2.0)
                     If omitted, auto-increments patch version
  --force            Override existing release (dangerous!)
  --update-packages  Trigger package manager update for current version
                     (without creating a new release)

Examples:
  $SCRIPT_NAME ~/projects/quickctx
  $SCRIPT_NAME ~/projects/quickctx 0.2.0
  $SCRIPT_NAME ~/projects/quickctx --force
  $SCRIPT_NAME ~/projects/quickctx 0.1.1 --force
  $SCRIPT_NAME ~/projects/quickctx --update-packages

EOF
    exit 1
}

# Parse arguments
parse_args() {
    if [[ $# -lt 1 ]]; then
        usage
    fi

    PROJECT_PATH="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                FORCE_MODE=true
                shift
                ;;
            --update-packages|-u)
                UPDATE_PACKAGES_ONLY=true
                shift
                ;;
            *)
                if [[ -z "$NEW_VERSION" ]]; then
                    NEW_VERSION="$1"
                else
                    error "Unknown argument: $1"
                    usage
                fi
                shift
                ;;
        esac
    done

    # Validate conflicting flags
    if [[ "$FORCE_MODE" == true && "$UPDATE_PACKAGES_ONLY" == true ]]; then
        die "Cannot use --force and --update-packages together"
    fi

    # Resolve to absolute path
    PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
}

# Pre-flight checks
check_prerequisites() {
    info "Running pre-flight checks..."

    # Check if gh is installed
    if ! command -v gh &> /dev/null; then
        die "GitHub CLI (gh) is not installed. Install: https://cli.github.com/"
    fi

    # Check if gh is authenticated
    if ! gh auth status &> /dev/null; then
        die "GitHub CLI is not authenticated. Run: gh auth login"
    fi

    # Check if cargo is installed
    if ! command -v cargo &> /dev/null; then
        die "Cargo is not installed"
    fi

    # Check if jq is installed (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        die "jq is not installed. Install: sudo apt install jq"
    fi

    success "All prerequisites satisfied"
}

check_project_directory() {
    info "Checking project directory: $PROJECT_PATH"

    if [[ ! -d "$PROJECT_PATH" ]]; then
        die "Project directory does not exist: $PROJECT_PATH"
    fi

    if [[ ! -f "$PROJECT_PATH/Cargo.toml" ]]; then
        die "Not a Rust project (Cargo.toml not found): $PROJECT_PATH"
    fi

    if [[ ! -d "$PROJECT_PATH/.git" ]]; then
        die "Not a git repository: $PROJECT_PATH"
    fi

    success "Project directory is valid"
}

check_working_tree() {
    info "Checking working tree status..."

    cd "$PROJECT_PATH"

    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        warning "Working tree has uncommitted changes:"
        echo ""
        git status --short
        echo ""

        # Check if only Cargo.toml and Cargo.lock are modified
        local modified_files
        # Check both staged and unstaged files
        modified_files=$(git diff --name-only HEAD | sort)
        local cargo_files_only=false

        # Check if modified files are only Cargo.toml and/or Cargo.lock
        if [[ "$modified_files" == "Cargo.lock" ]] || \
           [[ "$modified_files" == "Cargo.toml" ]] || \
           [[ "$modified_files" == $'Cargo.lock\nCargo.toml' ]]; then
            cargo_files_only=true
        fi

        if [[ "$cargo_files_only" == true ]]; then
            warning "Detected incomplete release (only Cargo files modified)"
            echo ""
            echo "This may be from a previous failed release attempt."
            echo ""
            echo "What would you like to do?"
            echo "  1) Rollback changes (git restore Cargo.toml Cargo.lock)"
            echo "  2) Continue with current changes"
            echo "  3) Drop to interactive shell"
            echo "  4) Abort"
            echo ""

            local choice
            read -r -p "$(echo -e "${YELLOW}?${NC} Choose [1-4]: ")" choice

            case "$choice" in
                1)
                    git restore Cargo.toml Cargo.lock
                    success "Rolled back Cargo.toml and Cargo.lock"
                    ;;
                2)
                    warning "Continuing with current changes"
                    ;;
                3)
                    warning "Dropping to interactive shell. Type 'exit' when done."
                    bash -i
                    check_working_tree
                    ;;
                4|*)
                    die "Release aborted by user"
                    ;;
            esac
        else
            # Other files modified
            echo "What would you like to do?"
            echo "  1) Stage all and commit (git add -A && git commit)"
            echo "  2) Stage tracked files only (git add --update . && git cmc)"
            echo "  3) Drop to interactive shell"
            echo "  4) Ignore and continue (NOT RECOMMENDED)"
            echo "  5) Abort"
            echo ""

            local choice
            read -r -p "$(echo -e "${YELLOW}?${NC} Choose [1-5]: ")" choice

            case "$choice" in
                1)
                    git add -A
                    local commit_msg
                    read -r -p "$(echo -e "${YELLOW}?${NC} Commit message: ")" commit_msg
                    if [[ -z "$commit_msg" ]]; then
                        die "Commit message cannot be empty"
                    fi
                    git commit -m "$commit_msg"
                    success "Changes committed"
                    ;;
                2)
                    # Check if git cmc alias exists
                    if ! git config --get alias.cmc &>/dev/null; then
                        warning "git cmc alias not found, using 'git commit' instead"
                        git add --update .
                        local commit_msg
                        read -r -p "$(echo -e "${YELLOW}?${NC} Commit message: ")" commit_msg
                        if [[ -z "$commit_msg" ]]; then
                            die "Commit message cannot be empty"
                        fi
                        git commit -m "$commit_msg"
                    else
                        git add --update .
                        git cmc
                    fi
                    success "Changes committed"
                    ;;
                3)
                    warning "Dropping to interactive shell. Type 'exit' when done."
                    bash -i
                    # Re-check after shell exit
                    check_working_tree
                    ;;
                4)
                    warning "Continuing with uncommitted changes (NOT RECOMMENDED)"
                    ;;
                5|*)
                    die "Release aborted by user"
                    ;;
            esac
        fi
    else
        success "Working tree is clean"
    fi
}

get_current_version() {
    local cargo_version
    cargo_version=$(grep -E '^version\s*=' "$PROJECT_PATH/Cargo.toml" | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')

    if [[ -z "$cargo_version" ]]; then
        die "Could not parse version from Cargo.toml"
    fi

    echo "$cargo_version"
}

get_latest_git_tag() {
    cd "$PROJECT_PATH"
    local latest_tag
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    # Remove 'v' prefix if present
    latest_tag="${latest_tag#v}"

    echo "$latest_tag"
}

get_latest_github_release() {
    cd "$PROJECT_PATH"
    local repo
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

    if [[ -z "$repo" ]]; then
        warning "Could not determine GitHub repository"
        echo ""
        return
    fi

    local latest_release
    latest_release=$(gh release list --limit 1 --json tagName -q '.[0].tagName' 2>/dev/null || echo "")

    # Remove 'v' prefix if present
    latest_release="${latest_release#v}"

    echo "$latest_release"
}

verify_versions() {
    local cargo_ver git_tag gh_release

    cargo_ver=$(get_current_version)
    git_tag=$(get_latest_git_tag)
    gh_release=$(get_latest_github_release)

    info "Version status:" >&2
    echo "  Cargo.toml:      $cargo_ver" >&2
    echo "  Latest git tag:  ${git_tag:-<none>}" >&2
    echo "  Latest GH release: ${gh_release:-<none>}" >&2
    echo "" >&2

    if [[ -n "$git_tag" && "$cargo_ver" != "$git_tag" ]]; then
        warning "Cargo.toml version doesn't match latest git tag!" >&2
    fi

    if [[ -n "$gh_release" && "$cargo_ver" != "$gh_release" ]]; then
        warning "Cargo.toml version doesn't match latest GitHub release!" >&2
    fi

    echo "$cargo_ver"
}

show_recent_history() {
    info "Recent commit history:" >&2
    echo "" >&2
    cd "$PROJECT_PATH"

    # Show last 10 commits with relative time
    git log --oneline --decorate --date=relative -10 --color=always 2>/dev/null | sed 's/^/  /' >&2 || true
    echo "" >&2

    info "Recent tags:" >&2
    echo "" >&2

    # Show last 10 tags with dates
    if git tag -l | head -1 &>/dev/null; then
        git tag -l --sort=-version:refname | head -10 | while read -r tag; do
            local tag_date
            tag_date=$(git log -1 --format="%ar" "$tag" 2>/dev/null || echo "unknown")
            printf "  %-20s %s\n" "$tag" "$tag_date" >&2
        done
    else
        echo "  <no tags yet>" >&2
    fi
    echo "" >&2
}

increment_patch_version() {
    local version="$1"

    # Parse version as major.minor.patch
    if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        die "Invalid version format: $version (expected: major.minor.patch)"
    fi

    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"

    # Increment patch
    ((patch++))

    echo "$major.$minor.$patch"
}

update_cargo_version() {
    local new_version="$1"

    info "Updating Cargo.toml to version $new_version..."

    cd "$PROJECT_PATH"

    # Update version in Cargo.toml
    sed -i.bak -E "0,/^version\s*=/{s/^version\s*=.*/version = \"$new_version\"/}" Cargo.toml
    rm -f Cargo.toml.bak

    # Update Cargo.lock
    cargo check --quiet 2>/dev/null || true

    success "Updated Cargo.toml and Cargo.lock"
}

create_release_commit() {
    local version="$1"

    info "Creating release commit..."

    cd "$PROJECT_PATH"

    git add Cargo.toml Cargo.lock

    # Check if project uses nix flake
    if [[ -f "$PROJECT_PATH/flake.nix" ]] && command -v nix &> /dev/null; then
        info "Detected flake.nix - running commit in nix environment..."

        # Suppress only the "dirty tree" warning from nix, show everything else
        local commit_output
        local commit_exit_code=0
        commit_output=$(nix develop --command git commit -m "chore(release): bump version to $version" 2>&1) || commit_exit_code=$?

        # Filter out the nix dirty tree warning
        echo "$commit_output" | grep -v "warning: Git tree.*is dirty" || true

        if [[ $commit_exit_code -eq 0 ]]; then
            success "Committed in nix environment with hooks"
        else
            warning "Commit in nix environment failed (exit code: $commit_exit_code)"
            info "Retrying with --no-verify..."
            git commit --no-verify -m "chore(release): bump version to $version"
        fi
    else
        # No flake.nix or nix not available, try normal commit
        if ! git commit -m "chore(release): bump version to $version" 2>/dev/null; then
            warning "Pre-commit hooks failed, committing with --no-verify..."
            git commit --no-verify -m "chore(release): bump version to $version"
        fi
    fi

    success "Created release commit"
}

create_and_push_tag() {
    local version="$1"
    local tag="v$version"

    info "Creating and pushing tag: $tag..."

    cd "$PROJECT_PATH"

    git tag "$tag"
    git push origin "$tag"

    success "Tag created and pushed"
}

push_branch() {
    info "Pushing branch..."

    cd "$PROJECT_PATH"

    local current_branch
    current_branch=$(git branch --show-current)

    git push origin "$current_branch"

    success "Branch pushed"
}

create_github_release() {
    local version="$1"
    local tag="v$version"

    info "Creating GitHub release: $tag..."

    cd "$PROJECT_PATH"

    gh release create "$tag" \
        --generate-notes \
        --title "$tag" \
        --notes "Release $version"

    success "GitHub release created: $tag"
    info "CI/CD workflows will now build and publish artifacts"
}

delete_github_release() {
    local version="$1"
    local tag="v$version"

    info "Deleting existing GitHub release: $tag..."

    cd "$PROJECT_PATH"

    if gh release view "$tag" &>/dev/null; then
        gh release delete "$tag" --yes
        success "Deleted GitHub release: $tag"
    else
        warning "No GitHub release found for $tag"
    fi
}

delete_and_recreate_tag() {
    local version="$1"
    local tag="v$version"

    info "Deleting and recreating tag: $tag..."

    cd "$PROJECT_PATH"

    # Delete local tag
    if git tag -l "$tag" | grep -q "$tag"; then
        git tag -d "$tag"
        success "Deleted local tag: $tag"
    fi

    # Delete remote tag
    if git ls-remote --tags origin | grep -q "refs/tags/$tag"; then
        git push origin ":refs/tags/$tag"
        success "Deleted remote tag: $tag"
    fi

    # Create new tag
    git tag "$tag"

    # Force push tag
    git push --force origin "$tag"

    success "Recreated and force-pushed tag: $tag"
}

normal_release_flow() {
    local current_version new_version

    current_version=$(verify_versions)

    # Show recent history for context
    show_recent_history

    # Determine new version
    if [[ -z "$NEW_VERSION" ]]; then
        new_version=$(increment_patch_version "$current_version")
        info "Auto-incrementing version: $current_version → $new_version"
    else
        new_version="$NEW_VERSION"
        info "Using specified version: $new_version"
    fi

    # Confirmation
    echo ""
    info "Release Summary:"
    echo "  Project: $PROJECT_PATH"
    echo "  Current version: $current_version"
    echo "  New version: $new_version"
    echo ""

    if ! confirm "Proceed with release?"; then
        die "Release aborted by user"
    fi

    # Execute release steps
    update_cargo_version "$new_version"
    create_release_commit "$new_version"
    push_branch
    create_and_push_tag "$new_version"
    create_github_release "$new_version"

    echo ""
    success "Release $new_version completed successfully!"
    info "Monitor CI/CD at: $(gh repo view --json url -q .url)/actions"
}

update_packages_flow() {
    local current_version target_version tool_name

    current_version=$(verify_versions)

    # Determine version to update
    if [[ -z "$NEW_VERSION" ]]; then
        target_version="$current_version"
        info "Using current version: $target_version"
    else
        target_version="$NEW_VERSION"
        info "Using specified version: $target_version"
    fi

    # Get repository info
    cd "$PROJECT_PATH"
    local repo
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")

    if [[ -z "$repo" ]]; then
        die "Could not determine GitHub repository"
    fi

    # Extract tool name from repo (e.g., CaddyGlow/quickctx -> quickctx)
    tool_name=$(basename "$repo")

    # Show what will be done
    echo ""
    info "Package Manager Update:"
    echo "  Repository: $repo"
    echo "  Tool: $tool_name"
    echo "  Version: $target_version"
    echo ""

    if ! confirm "Trigger package manager update workflow?"; then
        die "Package manager update aborted by user"
    fi

    # Check if update-package-managers workflow exists
    if [[ ! -f "$PROJECT_PATH/.github/workflows/update-package-managers.yml" ]]; then
        die "Workflow not found: .github/workflows/update-package-managers.yml"
    fi

    # Trigger the workflow via workflow_dispatch
    info "Triggering update-package-managers workflow..."

    if gh workflow run update-package-managers.yml -f version="$target_version" 2>/dev/null; then
        success "Package manager update workflow triggered!"
        echo ""
        info "Monitor workflow at: $(gh repo view --json url -q .url)/actions"
    else
        die "Failed to trigger workflow. Make sure the workflow has workflow_dispatch enabled."
    fi
}

force_release_flow() {
    local current_version target_version

    current_version=$(verify_versions)

    # Show recent history for context
    show_recent_history

    # Determine target version
    if [[ -z "$NEW_VERSION" ]]; then
        target_version="$current_version"
        warning "Force mode with current version: $target_version"
    else
        target_version="$NEW_VERSION"
        warning "Force mode with specified version: $target_version"
    fi

    # Strong warning
    echo ""
    error "⚠️  FORCE MODE - DESTRUCTIVE OPERATION ⚠️"
    echo ""
    echo "This will:"
    echo "  1. Delete GitHub release v$target_version"
    echo "  2. Delete and recreate git tag v$target_version"
    echo "  3. Force push tag"
    echo "  4. Create new GitHub release"
    echo ""
    warning "This operation is DANGEROUS and will rewrite history!"
    echo ""

    if ! confirm "Are you ABSOLUTELY sure?"; then
        die "Force release aborted by user"
    fi

    # Execute force release steps
    if [[ "$target_version" != "$current_version" ]]; then
        update_cargo_version "$target_version"
        create_release_commit "$target_version"
        push_branch
    fi

    delete_github_release "$target_version"
    delete_and_recreate_tag "$target_version"
    create_github_release "$target_version"

    echo ""
    success "Force release $target_version completed!"
    warning "Remember: This rewrote git history. Collaborators may need to sync."
}

# Main execution
main() {
    parse_args "$@"

    check_prerequisites
    check_project_directory

    if [[ "$UPDATE_PACKAGES_ONLY" == true ]]; then
        # Skip working tree check for package updates
        update_packages_flow
    else
        check_working_tree

        if [[ "$FORCE_MODE" == true ]]; then
            force_release_flow
        else
            normal_release_flow
        fi
    fi
}

main "$@"
