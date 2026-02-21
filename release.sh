#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# PureCal Release Script
# =============================================================================
# Automates version releases with LLM-powered semantic versioning and changelog
# generation. Generates Play Store changelogs in fastlane metadata format.
# Supports Gemini API (primary) and Ollama (fallback).
#
# Usage: ./release.sh
# Configuration: .release.config (optional)
# =============================================================================

# Colors for terminal output
COLOR_RESET='\033[0m'
COLOR_INFO='\033[0;34m'
COLOR_SUCCESS='\033[0;32m'
COLOR_WARN='\033[0;33m'
COLOR_ERROR='\033[0;31m'

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBSPEC_FILE="$PROJECT_ROOT/pubspec.yaml"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"
CONFIG_FILE="$PROJECT_ROOT/.release.config"
BACKUP_DIR="$PROJECT_ROOT/.release-backup"

# Default configuration
LLM_BACKEND="${LLM_BACKEND:-auto}"
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.0-flash-exp}"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3:latest}"
BUILD_APK="${BUILD_APK:-yes}"
CREATE_GITHUB_RELEASE="${CREATE_GITHUB_RELEASE:-yes}"
PUSH_TO_REMOTE="${PUSH_TO_REMOTE:-yes}"
WRITE_FASTLANE_CHANGELOGS="${WRITE_FASTLANE_CHANGELOGS:-yes}"
TRANSLATE_FASTLANE_CHANGELOGS="${TRANSLATE_FASTLANE_CHANGELOGS:-yes}"
FASTLANE_CHANGELOG_MAX_LENGTH="${FASTLANE_CHANGELOG_MAX_LENGTH:-500}"
DOCKER_FLUTTER_IMAGE="${DOCKER_FLUTTER_IMAGE:-ghcr.io/cirruslabs/flutter:3.38.4}"

# Trap for error handling (disabled during specific sections)
TRAP_ENABLED=1

# =============================================================================
# Logging Functions
# =============================================================================

log() {
    echo -e "${COLOR_INFO}[INFO]${COLOR_RESET} $*" >&2
}

success() {
    echo -e "${COLOR_SUCCESS}[SUCCESS]${COLOR_RESET} $*" >&2
}

warn() {
    echo -e "${COLOR_WARN}[WARN]${COLOR_RESET} $*" >&2
}

error() {
    echo -e "${COLOR_ERROR}[ERROR]${COLOR_RESET} $*" >&2
}

# =============================================================================
# Configuration Management
# =============================================================================

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading configuration from .release.config"
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi
}

# =============================================================================
# Version Parsing and Calculation
# =============================================================================

parse_version() {
    local version_line
    version_line=$(grep "^version:" "$PUBSPEC_FILE" | head -1)

    if [[ -z "$version_line" ]]; then
        error "No version found in pubspec.yaml"
        return 1
    fi

    local version
    version=$(echo "$version_line" | sed 's/version: *//' | tr -d '"' | tr -d "'")
    echo "$version"
}

extract_build_number() {
    local version="$1"

    # Extract build number using regex
    if [[ "$version" =~ \+([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        error "No build number found in version: $version"
        return 1
    fi
}

increment_version() {
    local current_version="$1"
    local bump_type="$2"

    # Parse version using regex: major.minor.patch-prerelease+build
    if [[ ! "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-zA-Z0-9.]+))?(\+([0-9]+))?$ ]]; then
        error "Invalid version format: $current_version"
        return 1
    fi

    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"
    local prerelease="${BASH_REMATCH[5]}"
    local build="${BASH_REMATCH[7]:-0}"

    # Increment build number
    build=$((build + 1))

    # Increment version based on bump type
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            error "Invalid bump type: $bump_type"
            return 1
            ;;
    esac

    # Construct new version
    local new_version="$major.$minor.$patch"
    if [[ -n "$prerelease" ]]; then
        new_version="$new_version-$prerelease"
    fi
    new_version="$new_version+$build"

    echo "$new_version"
}

# =============================================================================
# Git Operations
# =============================================================================

get_last_tag() {
    local last_tag
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    echo "$last_tag"
}

get_changes_since_tag() {
    local tag="$1"
    local changes

    if [[ -z "$tag" ]]; then
        # No previous tag, get all commits
        changes=$(git log --pretty=format:'%h|%an|%s' --reverse)
    else
        # Get commits since tag
        changes=$(git log "$tag"..HEAD --pretty=format:'%h|%an|%s' --reverse)
    fi

    echo "$changes"
}

get_diff_stats() {
    local tag="$1"

    if [[ -z "$tag" ]]; then
        git diff --stat 4b825dc95f33dcd0fee5c6d3d1f6b4f3f5f1c7f7 HEAD
    else
        git diff --stat "$tag"..HEAD
    fi
}

# =============================================================================
# LLM Backend Detection and API Calls
# =============================================================================

detect_llm_backend() {
    case "$LLM_BACKEND" in
        gemini)
            if [[ -n "$GEMINI_API_KEY" ]]; then
                echo "gemini"
                return 0
            else
                error "GEMINI_API_KEY not set but LLM_BACKEND=gemini"
                error "Get a free API key at: https://ai.google.dev/"
                return 1
            fi
            ;;
        ollama)
            if command -v ollama &> /dev/null; then
                echo "ollama"
                return 0
            else
                error "Ollama not found but LLM_BACKEND=ollama"
                error "Install from: https://ollama.ai/"
                return 1
            fi
            ;;
        auto)
            if [[ -n "$GEMINI_API_KEY" ]]; then
                echo "gemini"
                return 0
            elif command -v ollama &> /dev/null; then
                echo "ollama"
                return 0
            else
                error "No LLM backend available"
                error "Either set GEMINI_API_KEY (get free key at https://ai.google.dev/)"
                error "Or install Ollama (https://ollama.ai/)"
                return 1
            fi
            ;;
        *)
            error "Invalid LLM_BACKEND: $LLM_BACKEND (use: auto, gemini, ollama)"
            return 1
            ;;
    esac
}

call_gemini_api() {
    local prompt="$1"
    local model="${GEMINI_MODEL}"

    log "Calling Gemini API ($model)..."

    # Build JSON payload
    local payload
    payload=$(jq -n --arg prompt "$prompt" '{
        contents: [{
            parts: [{text: $prompt}]
        }]
    }')

    # Make API request
    local response
    response=$(curl -s -X POST \
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # Check for errors
    if [[ $(echo "$response" | jq -r '.error // empty') ]]; then
        error "Gemini API error: $(echo "$response" | jq -r '.error.message')"
        return 1
    fi

    # Extract text from response
    local result
    result=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // empty')

    if [[ -z "$result" ]]; then
        error "Empty response from Gemini API"
        return 1
    fi

    echo "$result"
}

call_ollama() {
    local prompt="$1"
    local model="${OLLAMA_MODEL}"

    log "Calling Ollama ($model)..."

    local result
    result=$(ollama run "$model" "$prompt" 2>/dev/null)

    if [[ -z "$result" ]]; then
        error "Empty response from Ollama"
        return 1
    fi

    echo "$result"
}

call_llm() {
    local prompt="$1"
    local backend

    backend=$(detect_llm_backend) || return 1

    case "$backend" in
        gemini)
            call_gemini_api "$prompt"
            ;;
        ollama)
            call_ollama "$prompt"
            ;;
    esac
}

# =============================================================================
# LLM Analysis Functions
# =============================================================================

analyze_changes_with_llm() {
    local current_version="$1"
    local changes="$2"
    local diff_stats="$3"

    local prompt
    prompt=$(cat <<EOF
You are a semantic versioning expert analyzing changes for a Flutter mobile app release.

Current version: $current_version

Recent changes since last release:
$changes

Summary statistics:
$diff_stats

Based on semantic versioning principles:
- MAJOR: Breaking changes, major feature rewrites, API incompatibilities
- MINOR: New features, significant enhancements, backward-compatible additions
- PATCH: Bug fixes, small improvements, dependency updates, internal refactoring

Analyze these changes and determine the appropriate version bump.

Respond with ONLY ONE WORD on the first line: "major", "minor", or "patch"

Then on a new line, provide a brief 1-2 sentence justification.
EOF
)

    call_llm "$prompt"
}

generate_changelog_with_llm() {
    local changes="$1"

    local prompt
    prompt=$(cat <<EOF
You are a technical writer creating changelog entries for a Flutter mobile app release.

Analyze the following changes and create a well-organized changelog entry.

Recent changes:
$changes

Instructions:
1. Categorize changes into: Added, Changed, Fixed, Removed
2. Write clear, user-focused descriptions (not just commit messages)
3. Combine related changes into single bullet points
4. Use professional technical writing style
5. Focus on what changed from a user/developer perspective

Format your response as:
### Added
- Description of new feature/capability
- Another new feature

### Changed
- Description of modification/enhancement
- Another change

### Fixed
- Description of bug fix
- Another fix

Omit sections with no changes. Be concise but informative.
EOF
)

    call_llm "$prompt"
}

format_changelog_for_playstore() {
    local markdown_content="$1"
    local max_length="${FASTLANE_CHANGELOG_MAX_LENGTH:-500}"

    # Convert markdown to plain text
    local plain_text
    plain_text=$(echo "$markdown_content" | \
        sed 's/^### //' | \
        sed 's/\*\*//g' | \
        sed 's/`//g' | \
        sed '/^$/N;/^\n$/D')

    # Truncate if exceeds max length
    if [[ ${#plain_text} -gt $max_length ]]; then
        # Find last complete sentence/bullet within limit
        local truncated
        truncated=$(echo "$plain_text" | cut -c1-$((max_length - 3)))

        # Trim to last newline or period
        truncated=$(echo "$truncated" | sed 's/\(.*[.\n]\).*/\1/')

        echo "${truncated}..."
    else
        echo "$plain_text"
    fi
}

translate_changelog_with_llm() {
    local english_content="$1"
    local target_language="$2"
    local max_length="${FASTLANE_CHANGELOG_MAX_LENGTH:-500}"

    local prompt
    prompt=$(cat <<EOF
You are a professional translator for mobile app store listings.

Translate the following changelog from English to $target_language.

Requirements:
1. Preserve the exact structure (sections, bullet points, line breaks)
2. Keep technical terms accurate and localized appropriately
3. Maintain professional tone suitable for app store listings
4. Keep the translation concise - maximum $max_length characters
5. Do NOT add explanations or extra text - only output the translated changelog

English changelog:
$english_content

Translate to $target_language:
EOF
)

    call_llm "$prompt"
}

parse_version_response() {
    local response="$1"

    # Extract first line (should be bump type)
    local bump_type
    bump_type=$(echo "$response" | head -1 | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    # Validate bump type
    if [[ ! "$bump_type" =~ ^(major|minor|patch)$ ]]; then
        error "Invalid bump type from LLM: $bump_type"
        return 1
    fi

    # Extract justification (rest of response)
    local justification
    justification=$(echo "$response" | tail -n +2 | sed '/^[[:space:]]*$/d')

    echo "$bump_type"
    echo "---"
    echo "$justification"
}

# =============================================================================
# File Operations
# =============================================================================

backup_files() {
    log "Creating backups..."

    mkdir -p "$BACKUP_DIR"

    if [[ -f "$PUBSPEC_FILE" ]]; then
        cp "$PUBSPEC_FILE" "$BACKUP_DIR/pubspec.yaml.bak"
    fi

    if [[ -f "$CHANGELOG_FILE" ]]; then
        cp "$CHANGELOG_FILE" "$BACKUP_DIR/CHANGELOG.md.bak"
    fi

    success "Backups created in .release-backup/"
}

rollback() {
    warn "Rolling back changes..."

    if [[ -f "$BACKUP_DIR/pubspec.yaml.bak" ]]; then
        cp "$BACKUP_DIR/pubspec.yaml.bak" "$PUBSPEC_FILE"
        log "Restored pubspec.yaml"
    fi

    if [[ -f "$BACKUP_DIR/CHANGELOG.md.bak" ]]; then
        cp "$BACKUP_DIR/CHANGELOG.md.bak" "$CHANGELOG_FILE"
        log "Restored CHANGELOG.md"
    fi

    warn "Rollback complete"
}

cleanup_backups() {
    if [[ -d "$BACKUP_DIR" ]]; then
        rm -rf "$BACKUP_DIR"
        log "Cleaned up backup directory"
    fi
}

create_fastlane_changelogs_structure() {
    local locales=("en-US" "es-ES" "ru-RU" "pl-PL" "be-BY")

    log "Creating fastlane changelogs directory structure..."

    for locale in "${locales[@]}"; do
        local dir="$PROJECT_ROOT/fastlane/metadata/android/$locale/changelogs"
        mkdir -p "$dir"
    done

    success "Fastlane changelogs structure created"
}

update_pubspec() {
    local new_version="$1"

    log "Updating pubspec.yaml to version $new_version..."

    # Detect OS for sed syntax
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"
    else
        # Linux
        sed -i "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"
    fi

    success "Updated pubspec.yaml"
}

update_changelog() {
    local version="$1"
    local changelog_content="$2"
    local date
    date=$(date +%Y-%m-%d)

    log "Updating CHANGELOG.md..."

    # Create CHANGELOG.md if it doesn't exist
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        cat > "$CHANGELOG_FILE" <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
    fi

    # Create temp file with new entry
    local temp_file
    temp_file=$(mktemp)

    local new_entry_file
    new_entry_file=$(mktemp)

    # Write new entry to temp file
    cat > "$new_entry_file" <<EOF

## [$version] - $date

$changelog_content

EOF

    # Insert new entry after the header
    awk '
        !inserted && /^$/ && prev_line ~ /^#/ {
            print
            while ((getline line < "'"$new_entry_file"'") > 0) {
                print line
            }
            close("'"$new_entry_file"'")
            inserted = 1
            next
        }
        { print }
        { prev_line = $0 }
    ' "$CHANGELOG_FILE" > "$temp_file"

    mv "$temp_file" "$CHANGELOG_FILE"
    rm -f "$new_entry_file"

    success "Updated CHANGELOG.md"
}

write_fastlane_changelog() {
    local build_number="$1"
    local content="$2"
    local locale="$3"

    local changelog_file="$PROJECT_ROOT/fastlane/metadata/android/$locale/changelogs/${build_number}.txt"

    # Ensure directory exists
    mkdir -p "$(dirname "$changelog_file")"

    # Write content
    echo "$content" > "$changelog_file"

    if [[ ! -f "$changelog_file" ]]; then
        error "Failed to write changelog for locale $locale"
        return 1
    fi
}

get_locale_language() {
    local locale="$1"
    case "$locale" in
        en-US) echo "English" ;;
        es-ES) echo "Spanish" ;;
        ru-RU) echo "Russian" ;;
        pl-PL) echo "Polish" ;;
        be-BY) echo "Belarusian" ;;
        *) echo "English" ;;
    esac
}

write_all_fastlane_changelogs() {
    local build_number="$1"
    local changelog_content="$2"

    # Format English version for Play Store
    local english_formatted
    english_formatted=$(format_changelog_for_playstore "$changelog_content")

    # Ensure directory structure exists
    create_fastlane_changelogs_structure

    if [[ "${TRANSLATE_FASTLANE_CHANGELOGS:-yes}" == "yes" ]]; then
        log "Writing and translating changelogs for build $build_number..."
    else
        log "Writing changelogs for build $build_number (translation disabled)..."
    fi

    # Write to all locales
    for locale in "en-US" "es-ES" "ru-RU" "pl-PL" "be-BY"; do
        local content
        local language
        language=$(get_locale_language "$locale")

        if [[ "$locale" == "en-US" ]] || [[ "${TRANSLATE_FASTLANE_CHANGELOGS:-yes}" != "yes" ]]; then
            # Use English version directly
            content="$english_formatted"
            log "  → $locale ($language)"
        else
            # Translate to target language
            log "  → $locale ($language) - translating..."
            content=$(translate_changelog_with_llm "$english_formatted" "$language") || {
                warn "Translation failed for $locale, using English as fallback"
                content="$english_formatted"
            }
        fi

        # Write the changelog file
        write_fastlane_changelog "$build_number" "$content" "$locale" || return 1
        log "    ✓ $locale"
    done

    if [[ "${TRANSLATE_FASTLANE_CHANGELOGS:-yes}" == "yes" ]]; then
        success "Fastlane changelogs written and translated for all locales"
    else
        success "Fastlane changelogs written to all locales (English only)"
    fi
}

# =============================================================================
# Build Functions
# =============================================================================

build_apk() {
    local version="$1"

    log "Building Android APK for version $version..."

    if [[ ! -f "$PROJECT_ROOT/.env.json" ]]; then
        error ".env.json not found. APK build requires this file."
        return 1
    fi

    log "Building release APK in Docker (this may take a few minutes)..."
    if ! docker run --rm \
        -v "$PROJECT_ROOT":/app \
        -w /app \
        -e SOURCE_DATE_EPOCH=0 \
        -e PUB_CACHE=/app/.pub-cache \
        "$DOCKER_FLUTTER_IMAGE" \
        bash -c "flutter clean > /dev/null 2>&1 && flutter build apk --dart-define-from-file=.env.json --release" 2>&1 | grep -E "(Built|ERROR|FAILURE)" >&2; then
        error "APK build failed"
        return 1
    fi

    local apk_path="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
    if [[ ! -f "$apk_path" ]]; then
        error "APK not found at $apk_path"
        return 1
    fi

    local versioned_apk="$PROJECT_ROOT/build/purecal-$version.apk"
    cp "$apk_path" "$versioned_apk"

    success "APK built successfully: $versioned_apk"
    echo "$versioned_apk"
}

# =============================================================================
# GitHub Release Functions
# =============================================================================

create_github_release() {
    local version="$1"
    local changelog_content="$2"
    local apk_path="$3"

    log "Creating GitHub release for v$version..."

    # Check gh CLI is installed
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) not installed"
        error "Install from: https://cli.github.com/"
        return 1
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        error "Not authenticated with GitHub"
        error "Run: gh auth login"
        return 1
    fi

    # Check if release already exists
    if gh release view "v$version" &> /dev/null; then
        warn "Release v$version already exists on GitHub"
        return 1
    fi

    # Create release with changelog and APK
    log "Uploading release and APK to GitHub..."
    local release_url

    if [[ -f "$apk_path" ]]; then
        release_url=$(gh release create "v$version" \
            "$apk_path" \
            --title "Release $version" \
            --notes "$changelog_content" \
            --latest 2>&1 | grep -o 'https://[^[:space:]]*' || echo "")
    else
        release_url=$(gh release create "v$version" \
            --title "Release $version" \
            --notes "$changelog_content" \
            --latest 2>&1 | grep -o 'https://[^[:space:]]*' || echo "")
    fi

    if [[ -z "$release_url" ]]; then
        error "Failed to create GitHub release"
        return 1
    fi

    success "GitHub release created: $release_url"
    echo "$release_url"
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_prerequisites() {
    log "Validating prerequisites..."

    # Check if in git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
        return 1
    fi

    # Check for clean working directory
    if [[ -n $(git status --porcelain) ]]; then
        error "Working directory is not clean. Commit or stash changes first."
        git status --short
        return 1
    fi

    # Check if .env.json exists (required for builds)
    if [[ "$BUILD_APK" == "yes" ]] && [[ ! -f "$PROJECT_ROOT/.env.json" ]]; then
        error ".env.json not found (required for APK builds)"
        error "Create .env.json with USDA_API_KEY or set BUILD_APK=no in .release.config"
        return 1
    fi

    # Check if on main/master branch (warn only)
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$current_branch" != "main" ]] && [[ "$current_branch" != "master" ]]; then
        warn "Not on main/master branch (current: $current_branch)"
        read -rp "Continue anyway? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Aborted by user"
            exit 1
        fi
    fi

    # Check for required tools
    if ! command -v jq &> /dev/null; then
        error "jq not installed (required for JSON processing)"
        error "Install with: brew install jq"
        return 1
    fi

    if [[ "$BUILD_APK" == "yes" ]] && ! command -v docker &> /dev/null; then
        error "Docker not installed (required for reproducible APK builds)"
        error "Install from: https://docs.docker.com/get-docker/"
        return 1
    fi

    if [[ "$CREATE_GITHUB_RELEASE" == "yes" ]] && ! command -v gh &> /dev/null; then
        warn "GitHub CLI not installed (required for GitHub releases)"
        warn "Install from: https://cli.github.com/"
        warn "Continuing without GitHub release creation..."
        CREATE_GITHUB_RELEASE=no
    fi

    # Validate LLM backend availability
    if ! detect_llm_backend > /dev/null; then
        return 1
    fi

    success "All prerequisites validated"
    return 0
}

# =============================================================================
# Error Handler
# =============================================================================

error_handler() {
    local line_number=$1

    if [[ $TRAP_ENABLED -eq 1 ]]; then
        error "Script failed at line $line_number"
        rollback
        exit 1
    fi
}

trap 'error_handler $LINENO' ERR

# =============================================================================
# Usage Function
# =============================================================================

show_usage() {
    cat << EOF
PureCal Release Script

Usage: ./release.sh [OPTIONS]

Options:
  --bump=TYPE         Override LLM suggestion with specific bump type
                      TYPE: major, minor, or patch
                      Example: ./release.sh --bump=minor

  --version=VERSION   Set exact version (bypasses LLM analysis)
                      Example: ./release.sh --version=2.0.0-rc.1+10

  --help             Show this help message

Without options, the script uses LLM to analyze changes and suggest
the appropriate semantic version bump.

Configuration:
  Create .release.config to customize LLM backend, build options, etc.
  See .release.config.example for available options.

Examples:
  ./release.sh                        # LLM-powered version bump
  ./release.sh --bump=patch           # Force patch version bump
  ./release.sh --version=2.0.0+1      # Set exact version
EOF
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    local bump_type_override=""
    local version_override=""

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --bump=*)
                bump_type_override="${1#*=}"
                if [[ ! "$bump_type_override" =~ ^(major|minor|patch)$ ]]; then
                    error "Invalid bump type: $bump_type_override (use: major, minor, patch)"
                    exit 1
                fi
                shift
                ;;
            --version=*)
                version_override="${1#*=}"
                # Validate version format
                if [[ ! "$version_override" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-zA-Z0-9.]+))?(\+([0-9]+))?$ ]]; then
                    error "Invalid version format: $version_override"
                    error "Expected format: major.minor.patch[-prerelease][+build]"
                    exit 1
                fi
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
        esac
    done

    log "PureCal Release Script"
    echo ""

    # Load configuration
    load_config

    # Validate prerequisites
    if ! validate_prerequisites; then
        exit 1
    fi

    echo ""

    # Get current version
    local current_version
    current_version=$(parse_version) || exit 1
    log "Current version: $current_version"

    # Get last tag and changes
    local last_tag
    last_tag=$(get_last_tag)

    if [[ -z "$last_tag" ]]; then
        log "No previous tags found (first release)"
    else
        log "Last tag: $last_tag"
    fi

    # Get changes since last tag
    local changes
    changes=$(get_changes_since_tag "$last_tag")

    if [[ -z "$changes" ]]; then
        warn "No commits since last tag"
        read -rp "Continue anyway? [y/N] " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log "Aborted by user"
            exit 0
        fi
        changes="No changes"
    fi

    # Get diff stats
    local diff_stats
    diff_stats=$(get_diff_stats "$last_tag")

    local bump_type=""
    local justification=""
    local new_version=""
    local formatted_changes=""

    # Format changes for LLM/changelog
    formatted_changes=$(echo "$changes" | awk -F'|' '{printf "- [%s] %s (by %s)\n", $1, $3, $2}')

    # Determine version based on overrides or LLM analysis
    if [[ -n "$version_override" ]]; then
        # Use exact version specified by user
        new_version="$version_override"
        bump_type="manual"
        justification="Version manually specified via --version flag"

        echo ""
        log "Using manually specified version: $new_version"

    elif [[ -n "$bump_type_override" ]]; then
        # Use bump type specified by user
        bump_type="$bump_type_override"
        justification="Bump type manually specified via --bump flag"

        echo ""
        log "Using manually specified bump type: $bump_type"

        # Calculate new version
        new_version=$(increment_version "$current_version" "$bump_type") || exit 1

    else
        # Use LLM to analyze and suggest version bump
        echo ""
        log "Analyzing changes with LLM..."

        # Analyze with LLM
        local llm_response
        llm_response=$(analyze_changes_with_llm "$current_version" "$formatted_changes" "$diff_stats") || {
            error "Failed to analyze changes with LLM"
            exit 1
        }

        # Parse LLM response
        local parsed_response
        parsed_response=$(parse_version_response "$llm_response") || exit 1

        bump_type=$(echo "$parsed_response" | head -1)
        justification=$(echo "$parsed_response" | sed '1,/^---$/d')

        echo ""
        success "LLM suggests: $bump_type"
        log "Justification: $justification"

        # Calculate new version
        new_version=$(increment_version "$current_version" "$bump_type") || exit 1
    fi

    echo ""
    log "Version change: $current_version → $new_version"
    echo ""

    # Confirm with user
    read -rp "Proceed with release? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log "Aborted by user"
        exit 0
    fi

    echo ""

    # Create backups
    backup_files

    # Update pubspec.yaml
    update_pubspec "$new_version"

    # Generate changelog with LLM
    log "Generating changelog with LLM..."
    local changelog_content
    changelog_content=$(generate_changelog_with_llm "$formatted_changes") || {
        error "Failed to generate changelog with LLM"
        rollback
        exit 1
    }

    # Update CHANGELOG.md
    update_changelog "$new_version" "$changelog_content"

    # Write fastlane changelogs
    if [[ "${WRITE_FASTLANE_CHANGELOGS:-yes}" == "yes" ]]; then
        echo ""
        log "Generating fastlane changelogs for Play Store..."

        local build_number
        build_number=$(extract_build_number "$new_version") || {
            error "Failed to extract build number from version"
            rollback
            exit 1
        }

        write_all_fastlane_changelogs "$build_number" "$changelog_content" || {
            error "Failed to write fastlane changelogs"
            rollback
            exit 1
        }

        success "Fastlane changelogs written for build $build_number"
    fi

    echo ""
    log "Review CHANGELOG.md entry:"
    echo "─────────────────────────────────────────"
    echo "$changelog_content"
    echo "─────────────────────────────────────────"
    echo ""

    read -rp "Edit CHANGELOG.md before committing? [y/N] " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} "$CHANGELOG_FILE"
    fi

    echo ""

    # Git operations (disable trap during this section)
    log "Creating git commit and tag..."

    # Stage version and changelog files
    git add "$PUBSPEC_FILE" "$CHANGELOG_FILE"

    # Stage fastlane changelogs if they were generated
    if [[ "${WRITE_FASTLANE_CHANGELOGS:-yes}" == "yes" ]]; then
        local build_number
        build_number=$(extract_build_number "$new_version")
        git add "fastlane/metadata/android/*/changelogs/${build_number}.txt"
    fi

    git commit -m "Release $new_version"
    git tag -a "v$new_version" -m "Release $new_version"

    success "Git commit and tag created"

    # From this point, errors should not rollback (release already created locally)
    TRAP_ENABLED=0

    # Push to remote
    if [[ "$PUSH_TO_REMOTE" == "yes" ]]; then
        echo ""
        log "Pushing to remote repository..."

        if git push && git push --tags; then
            success "Pushed to remote repository"
        else
            error "Failed to push to remote"
            error "Run manually: git push && git push --tags"
        fi
    fi

    # Build APK
    local apk_path=""
    if [[ "$BUILD_APK" == "yes" ]]; then
        echo ""
        if apk_path=$(build_apk "$new_version"); then
            success "APK build completed"
        else
            warn "APK build failed, but release is complete"
            warn "Build manually with: ./release.sh or run the Docker build command"
        fi
    fi

    # Create GitHub release
    local release_url=""
    if [[ "$CREATE_GITHUB_RELEASE" == "yes" ]]; then
        echo ""
        if release_url=$(create_github_release "$new_version" "$changelog_content" "$apk_path"); then
            success "GitHub release created"
        else
            warn "GitHub release creation failed, but local release is complete"
            warn "Create manually with: gh release create v$new_version"
        fi
    fi

    # Cleanup
    cleanup_backups

    # Success summary
    echo ""
    echo "═════════════════════════════════════════"
    success "Release $new_version completed successfully!"
    echo "═════════════════════════════════════════"
    echo ""
    log "Summary:"
    log "  Version: $current_version → $new_version"
    log "  Bump type: $bump_type"
    log "  Git tag: v$new_version"

    if [[ -n "$apk_path" ]] && [[ -f "$apk_path" ]]; then
        log "  APK: $apk_path"
    fi

    if [[ -n "$release_url" ]]; then
        log "  Release URL: $release_url"
    fi

    echo ""
    log "Next steps:"

    if [[ "$PUSH_TO_REMOTE" != "yes" ]]; then
        log "  - Push changes: git push && git push --tags"
    fi

    if [[ "$BUILD_APK" != "yes" ]]; then
        log "  - Build APK: run ./release.sh with BUILD_APK=yes"
    fi

    if [[ "$CREATE_GITHUB_RELEASE" != "yes" ]] || [[ -z "$release_url" ]]; then
        log "  - Create GitHub release: gh release create v$new_version"
    fi

    echo ""
}

# Run main function
main "$@"
