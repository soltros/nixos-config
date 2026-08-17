#!/usr/bin/env bash

# Deployment script for NixOS Flake

set -e

# Get the directory where this script is located
FLAKE_DIR="$(dirname $(readlink -f $0))"
# Automatically pull the hostname from flake.nix
HOST=$(awk -F'"' '/hostname =/ {print $2}' "$FLAKE_DIR/flake.nix")

cd "$FLAKE_DIR"

# Initialize git if it's not already initialized.
# Flakes require files to be tracked by git if a .git folder exists,
# so we ensure it's set up and tracking our files properly.
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

echo "Adding changes to git index..."
git add .

# Mark the directory as safe for git when running as root (solves the libgit2 error)
sudo git config --global --add safe.directory "$FLAKE_DIR"

echo "Rebuilding NixOS configuration..."
sudo nixos-rebuild switch --flake ".#${HOST}" --impure

echo "Deployment complete!"
