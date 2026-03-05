#!/bin/bash
# Release script for init-agent
# Usage: ./scripts/release.sh v0.1.0

set -e

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v0.1.0"
    exit 1
fi

# Validate version format
if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format vX.Y.Z (e.g., v0.1.0)"
    exit 1
fi

echo "🚀 Preparing release $VERSION"

# Check we're on main branch
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
    echo "Error: Must be on main branch (currently on $BRANCH)"
    exit 1
fi

# Check working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working directory is not clean. Commit or stash changes."
    git status
    exit 1
fi

# Run tests
echo "📋 Running tests..."
make test

# Update version in source
echo "📝 Updating version..."
sed -i.bak "s/const VERSION = \"[^\"]*\";/const VERSION = \"$VERSION\";/" src/main.zig
rm -f src/main.zig.bak

# Commit version bump
git add src/main.zig
git commit -m "chore: Bump version to $VERSION"

# Create tag
echo "🏷️  Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# Push
echo "📤 Pushing to origin..."
git push origin main
git push origin "$VERSION"

echo ""
echo "✅ Release $VERSION prepared!"
echo ""
echo "GitHub Actions will now build the release binaries."
echo "Check progress at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/actions"
echo ""
echo "When builds complete, the release will be available at:"
echo "  https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/releases/tag/$VERSION"
