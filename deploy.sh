#!/usr/bin/env bash

# Deployment script for NixOS Flake

set -e

# Get the directory where this script is located
FLAKE_DIR="$(dirname $(readlink -f $0))"
# Automatically pull the hostname from flake.nix
HOST=$(hostname)

cd "$FLAKE_DIR"

# Use the current machine's hardware config if available
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo "Syncing /etc/nixos/hardware-configuration.nix into repo..."
    cp /etc/nixos/hardware-configuration.nix "$FLAKE_DIR/hardware-configuration.nix"
fi

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
sudo nixos-rebuild switch --flake "${FLAKE_DIR}#${HOST}" --impure

echo "Deployment complete!"
