#!/bin/bash

# Function to display usage information
show_usage() {
  echo "Usage: $0 [major|minor|patch|tag|X.Y.Z[-identifier]]"
  echo "  major - Bump the major version (X.0.0)"
  echo "  minor - Bump the minor version (0.X.0)"
  echo "  patch - Bump the patch version (0.0.X)"
  echo "  tag   - Tag the git repository with the current version"
  echo "  X.Y.Z[-identifier] - Set version explicitly (e.g., 1.2.3 or 1.2.3-beta)"
  exit 1
}

# Check if an argument was provided
if [ $# -eq 0 ]; then
  show_usage
fi

# Get the current version from package.json
CURRENT_VERSION=$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4)
echo "Current version: $CURRENT_VERSION"

# Handle the tag command
if [ "$1" == "tag" ]; then
  # Check if the repository has uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "Error: Repository has uncommitted changes. Commit or stash them before tagging."
    exit 1
  fi
  
  echo "Tagging git repository with version v$CURRENT_VERSION"
  git tag -a "v$CURRENT_VERSION" -m "Version $CURRENT_VERSION"
  echo "Tag created. Use 'git push origin v$CURRENT_VERSION' to push the tag to remote."
  exit 0
fi

# Check if the argument is a version string
if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
  # Set version explicitly
  NEW_VERSION="$1"
else
  # Extract version components and identifier from current version
  if [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(-[a-zA-Z0-9]+)?$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    IDENTIFIER="${BASH_REMATCH[4]}"  # This will include the hyphen
  else
    echo "Error: Current version format not recognized"
    exit 1
  fi

  # Bump the version based on the argument
  case "$1" in
    major)
      MAJOR=$((MAJOR + 1))
      MINOR=0
      PATCH=0
      ;;
    minor)
      MINOR=$((MINOR + 1))
      PATCH=0
      ;;
    patch)
      PATCH=$((PATCH + 1))
      ;;
    *)
      echo "Invalid argument: $1"
      show_usage
      ;;
  esac

  # Create the new version string, preserving the identifier
  NEW_VERSION="$MAJOR.$MINOR.$PATCH$IDENTIFIER"
fi

echo "New version: $NEW_VERSION"

# Update package.json
sed -i.bak "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" package.json && rm package.json.bak

# Update Cargo.toml in src-tauri
sed -i.bak "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" src-tauri/Cargo.toml && rm src-tauri/Cargo.toml.bak

# Update tauri.conf.json
sed -i.bak "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" src-tauri/tauri.conf.json && rm src-tauri/tauri.conf.json.bak

echo "Version bumped to $NEW_VERSION"
echo "To tag this version, run: $0 tag"

