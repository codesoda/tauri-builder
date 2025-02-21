#!/bin/bash

# Function to get current version from package.json
get_current_version() {
    if [ -f "package.json" ]; then
        echo $(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4)
    else
        echo "0.0.0"
    fi
}

# Function to bump version based on type
bump_version() {
    local version=$1
    local bump_type=$2
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    local revision=$(echo $version | cut -d. -f3 | cut -d- -f1)
    local suffix=$(echo $version | grep -o -- '-.*$' || echo '')

    case $bump_type in
        "major")
            echo "$((major + 1)).0.0${suffix}"
            ;;
        "minor")
            echo "${major}.$((minor + 1)).0${suffix}"
            ;;
        "revision")
            echo "${major}.${minor}.$((revision + 1))${suffix}"
            ;;
        *)
            # If bump_type is actually a version number, return it
            if [[ $bump_type =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
                echo "$bump_type"
            else
                echo "invalid"
            fi
            ;;
    esac
}

CURRENT_VERSION=$(get_current_version)

# Check if version argument is provided
if [ $# -ne 1 ]; then
    NEXT_VERSION=$(bump_version "$CURRENT_VERSION" "revision")
    echo "Usage: $0 <version|major|minor|revision>"
    echo "Current version: $CURRENT_VERSION"
    echo "Examples:"
    echo "  $0 $NEXT_VERSION"
    echo "  $0 major"
    echo "  $0 minor"
    echo "  $0 revision"
    exit 1
fi

VERSION_ARG=$1
NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$VERSION_ARG")

if [ "$NEW_VERSION" = "invalid" ]; then
    echo "Error: Invalid argument. Must be 'major', 'minor', 'revision' or a valid version number (e.g., 1.0.7 or 1.0.7-beta)"
    exit 1
fi

# Update package.json
if [ -f "package.json" ]; then
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" package.json
    rm package.json.bak
    echo "Updated package.json version to $NEW_VERSION"
else
    echo "Warning: package.json not found"
fi

# Update Cargo.toml
if [ -f "src-tauri/Cargo.toml" ]; then
    sed -i.bak "s/^version = \"[^\"]*\"/version = \"$NEW_VERSION\"/" src-tauri/Cargo.toml
    rm src-tauri/Cargo.toml.bak
    echo "Updated Cargo.toml version to $NEW_VERSION"
else
    echo "Warning: src-tauri/Cargo.toml not found"
fi

# Update tauri.conf.json
if [ -f "src-tauri/tauri.conf.json" ]; then
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"$NEW_VERSION\"/" src-tauri/tauri.conf.json
    rm src-tauri/tauri.conf.json.bak
    echo "Updated tauri.conf.json version to $NEW_VERSION"
else
    echo "Warning: src-tauri/tauri.conf.json not found"
fi

echo "Version bump complete!"
