#!/usr/bin/env bash

# Deployment script for NixOS Flake
#
# Per-machine branch model:
#   master -> desktop hardware/software config
#   laptop -> laptop hardware/software config
# Each branch carries its OWN committed hardware-configuration.nix, so this
# script never overwrites it from /etc/nixos. The branch you are on is already
# the correct config for this machine.
#
# If hardware actually changes (new disk, GPU, ...):
#   sudo nixos-generate-config --root /
#   cp /etc/nixos/hardware-configuration.nix <repo>/hardware-configuration.nix
# then commit it on THIS machine's branch via lazygit.

set -e

FLAKE_DIR="$(dirname $(readlink -f $0))"
HOST=$(hostname)

cd "$FLAKE_DIR"

# Mark the directory as safe for git when running as root (solves the libgit2 error)
sudo git config --global --add safe.directory "$FLAKE_DIR"

echo "Rebuilding NixOS configuration for ${HOST}..."
sudo nixos-rebuild switch --flake "${FLAKE_DIR}#${HOST}" --impure

echo "Deployment complete!"
