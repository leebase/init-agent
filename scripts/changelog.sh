#!/bin/bash
#
# Changelog Generator for init-agent
# Generates CHANGELOG.md from conventional git commits
#

set -e

CHANGELOG_FILE="CHANGELOG.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Get the latest tag, or use "v0.0.0" if none exists
get_latest_tag() {
    local latest_tag
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    echo "$latest_tag"
}

# Get version from git tags or use provided version
get_version() {
    local version="$1"
    if [ -n "$version" ]; then
        echo "$version"
    else
        local latest_tag
        latest_tag=$(get_latest_tag)
        if [ -n "$latest_tag" ]; then
            echo "$latest_tag"
        else
            echo "v0.1.0"
        fi
    fi
}

# Get current date in ISO format (YYYY-MM-DD)
get_date() {
    date +%Y-%m-%d
}

# Parse commit type from message
parse_commit_type() {
    local message="$1"
    
    # Use sed to extract the type prefix from the commit message
    # Matches patterns like "feat:", "feat(scope):", "fix:", etc.
    local type
    type=$(echo "$message" | sed -n 's/^\([a-zA-Z]*\)[(:].*/\1/p')
    
    if [ -z "$type" ]; then
        echo "other"
        return
    fi
    
    case "$type" in
        feat|fix|docs|chore|test|refactor|style|perf|ci|build)
            echo "$type"
            ;;
        *)
            echo "other"
            ;;
    esac
}

# Get section title for commit type
get_section_title() {
    local type="$1"
    case "$type" in
        feat) echo "Features" ;;
        fix) echo "Bug Fixes" ;;
        docs) echo "Documentation" ;;
        chore) echo "Chores" ;;
        test) echo "Tests" ;;
        refactor) echo "Refactoring" ;;
        style) echo "Styles" ;;
        perf) echo "Performance" ;;
        ci) echo "CI/CD" ;;
        build) echo "Build System" ;;
        *) echo "Other" ;;
    esac
}

# Generate changelog content for a version range
generate_version_content() {
    local version="$1"
    local date_str="$2"
    local since_tag="$3"
    
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    # Initialize temp files for each type
    local types=("feat" "fix" "docs" "chore" "test" "refactor" "style" "perf" "ci" "build" "other")
    for t in "${types[@]}"; do
        touch "$temp_dir/$t.txt"
    done
    
    # Determine git log range
    local git_log_cmd="git log --pretty=format:\"%h %s\" --no-merges"
    if [ -n "$since_tag" ]; then
        git_log_cmd="$git_log_cmd \"${since_tag}..HEAD\""
    fi
    
    # Parse commits and categorize
    eval "$git_log_cmd" | while IFS= read -r line; do
        [ -z "$line" ] && continue
        
        # Extract hash and message
        local hash="${line%% *}"
        local message="${line#* }"
        
        # Parse commit type
        local commit_type
        commit_type=$(parse_commit_type "$message")
        
        # Clean up the message (remove type prefix)
        local clean_message
        clean_message=$(echo "$message" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//')
        
        # Format: - [abc1234] clean message
        local formatted="- ${message}"
        
        # Append to appropriate file
        echo "$formatted" >> "$temp_dir/$commit_type.txt"
    done
    
    # Build the version section
    echo "## [$version] - $date_str"
    echo ""
    
    # Output sections in order of importance
    local ordered_types=("feat" "fix" "perf" "refactor" "docs" "test" "build" "ci" "chore" "style" "other")
    
    for t in "${ordered_types[@]}"; do
        local file="$temp_dir/$t.txt"
        if [ -s "$file" ]; then
            echo "### $(get_section_title "$t")"
            cat "$file"
            echo ""
        fi
    done
}

# Generate full changelog
generate_changelog() {
    local version
    version=$(get_version "${1:-}")
    local date_str
    date_str=$(get_date)
    local since_tag="${2:-}"
    
    print_info "Generating changelog for version $version..."
    
    local temp_changelog
    temp_changelog=$(mktemp)
    trap "rm -f $temp_changelog" EXIT
    
    # Write header
    cat > "$temp_changelog" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF

    # Generate new version content
    generate_version_content "$version" "$date_str" "$since_tag" >> "$temp_changelog"
    
    # If existing changelog exists, append old versions (skip header)
    if [ -f "$CHANGELOG_FILE" ]; then
        print_info "Appending existing changelog entries..."
        # Skip the header (first 7 lines) and add the rest
        tail -n +8 "$CHANGELOG_FILE" >> "$temp_changelog"
    fi
    
    # Move temp file to final location
    mv "$temp_changelog" "$CHANGELOG_FILE"
    
    print_info "Changelog generated: $CHANGELOG_FILE"
}

# Update changelog by prepending a new version
update_changelog() {
    local version="$1"
    local since_tag="$2"
    
    if [ -z "$version" ]; then
        print_error "Version required for update. Use: $0 update <version> [since-tag]"
        exit 1
    fi
    
    local date_str
    date_str=$(get_date)
    
    print_info "Updating changelog with version $version..."
    
    local temp_changelog
    temp_changelog=$(mktemp)
    trap "rm -f $temp_changelog" EXIT
    
    # Write header
    cat > "$temp_changelog" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF

    # Generate new version content
    generate_version_content "$version" "$date_str" "$since_tag" >> "$temp_changelog"
    
    # If existing changelog exists, append old versions (skip header and first version)
    if [ -f "$CHANGELOG_FILE" ]; then
        print_info "Preserving existing changelog entries..."
        # Skip header (7 lines) and find where the second version starts
        # This is a bit tricky - we append everything after the first version section
        local in_first_version=true
        local line_count=0
        local skip_until_next_version=false
        
        tail -n +8 "$CHANGELOG_FILE" | while IFS= read -r line; do
            ((line_count++))
            
            # Check if we've reached the next version (## [ at start of line)
            if [[ "$line" =~ ^##\ \[ && "$skip_until_next_version" == false ]]; then
                if [ "$in_first_version" = true ]; then
                    in_first_version=false
                    skip_until_next_version=true
                    continue
                fi
            fi
            
            # If we're skipping until next version and find it, start outputting
            if [ "$skip_until_next_version" = true ]; then
                if [[ "$line" =~ ^##\ \[ ]]; then
                    skip_until_next_version=false
                    echo "$line"
                fi
                continue
            fi
            
            # Output line if not in first version
            if [ "$in_first_version" = false ] || [ "$skip_until_next_version" = false ]; then
                if [ "$in_first_version" = false ]; then
                    echo "$line"
                fi
            fi
        done >> "$temp_changelog"
    fi
    
    # Move temp file to final location
    mv "$temp_changelog" "$CHANGELOG_FILE"
    
    print_info "Changelog updated: $CHANGELOG_FILE"
}

# Preview mode - show what would be generated without writing
preview_changelog() {
    local version
    version=$(get_version "${1:-}")
    local date_str
    date_str=$(get_date)
    local since_tag="${2:-}"
    
    print_info "Previewing changelog for version $version..."
    echo ""
    
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    
    generate_version_content "$version" "$date_str" "$since_tag"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [command] [options]

Commands:
  generate [version] [since-tag]  Generate full changelog (default)
  update <version> [since-tag]    Prepend new version to existing changelog
  preview [version] [since-tag]   Preview changelog without writing
  help                            Show this help message

Arguments:
  version     Version tag (e.g., v1.0.0). Auto-detected from git tags if not provided.
  since-tag   Git tag to generate changelog from (e.g., v0.9.0). Uses all commits if not provided.

Examples:
  $0                              # Generate changelog with auto-detected version
  $0 generate v1.0.0              # Generate changelog for v1.0.0
  $0 generate v1.0.0 v0.9.0       # Generate changelog for commits since v0.9.0
  $0 update v1.1.0 v1.0.0         # Add v1.1.0 section to existing changelog
  $0 preview                      # Preview changelog without writing

Supported Commit Types:
  feat:     → Features
  fix:      → Bug Fixes
  docs:     → Documentation
  chore:    → Chores
  test:     → Tests
  refactor: → Refactoring
  style:    → Styles
  perf:     → Performance
  ci:       → CI/CD
  build:    → Build System

EOF
}

# Main function
main() {
    local command="${1:-generate}"
    
    case "$command" in
        generate|gen|g)
            generate_changelog "${2:-}" "${3:-}"
            ;;
        update|u)
            update_changelog "${2:-}" "${3:-}"
            ;;
        preview|p)
            preview_changelog "${2:-}" "${3:-}"
            ;;
        help|-h|--help)
            show_usage
            ;;
        *)
            # If first arg looks like a version (starts with v or number), treat as generate
            if [[ "$command" =~ ^v[0-9] ]] || [[ "$command" =~ ^[0-9]\.[0-9] ]]; then
                generate_changelog "$command" "${2:-}"
            else
                print_error "Unknown command: $command"
                show_usage
                exit 1
            fi
            ;;
    esac
}

main "$@"
