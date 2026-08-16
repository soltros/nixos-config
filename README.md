# NixOS Configuration

NixOS system configuration managed as a flake.

## Contents

- `flake.nix` — system flake definition
- `flake.lock` — flake lockfile
- `hardware-configuration.nix` — hardware-specific settings
- `modules/` — modular configuration fragments

## Modules

- `amdgpu.nix` — AMD GPU setup
- `derriks-apps.nix` — application packages
- `gamemode.nix` — gaming performance mode
- `ssh-server.nix` — SSH server
- `steam.nix` — Steam
- `tailscale-support.nix` — Tailscale
- `unsecure-packages.nix` — allowed unfree packages
- `virtualization-support.nix` — virtualization

## Usage

Rebuild the system:

```bash
sudo nixos-rebuild switch --flake /home/derrik/nixos-config
```

## Notes

- Target machine: NixOS on amd64
- Default Hermes model: `stepfun/step-3.7-flash:free`
