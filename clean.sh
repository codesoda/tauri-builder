#!/bin/bash

# Find all directories that have a Cargo.toml file and run cargo clean in them
find . -name 'Cargo.toml' -type f | while read -r file; do
    dir=$(dirname "$file")
    echo "Cleaning $dir"
    (cd "$dir" && cargo clean)
done

echo "Cleanup of target directories completed."

