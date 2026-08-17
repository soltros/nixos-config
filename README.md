# NixOS Configuration

NixOS system configuration managed as a flake, designed for deployment across multiple machines with hostname-conditional modules.

## Repository Structure

- `flake.nix`: system flake definition, inputs, and host configuration
- `flake.lock`: locked dependency versions
- `deploy.sh`: deployment script for applying the configuration
- `modules/`: modular configuration fragments
- `hardware-configuration.nix`: tracked in repo and overwritten by `deploy.sh` from `/etc/nixos/hardware-configuration.nix` on each machine

## Modules

- `amdgpu.nix`: AMD GPU configuration via the open-source amdgpu driver
- `intelgpu.nix`: Intel GPU configuration via the i915 driver
- `derriks-apps.nix`: application package set
- `gamemode.nix`: gaming performance mode
- `steam.nix`: Steam runtime and dependencies
- `tailscale-support.nix`: Tailscale mesh VPN
- `unsecure-packages.nix`: allowed unfree packages
- `ssh-server.nix`: OpenSSH server
- `virtualization-support.nix`: virtualization tools and libvirt

## Hostname-Conditional Behavior

The flake automatically selects modules based on the machine hostname:

- `b450m-d3sh`: desktop with AMD GPU; enables `hardware.amd`
- `13-1315u`: laptop with Intel Raptor Lake i3; enables `hardware.intel` and Intel microcode

Both GPU modules are included in the flake, but only the matching one is enabled per host.

## Desktop Environment

- X11 windowing system
- Pantheon desktop environment
- LightDM display manager
- PipeWire audio with ALSA and PulseAudio compatibility
- Flatpak support
- CUPS printing support

## System Packages

Installed via `derriks-apps.nix`:

- bitwarden-desktop
- git
- python312
- btrfs-progs
- appimage-run
- papirus-icon-theme
- libreoffice-qt
- spotify
- tailscale
- vlc
- gimp
- wget
- zettlr
- winetricks
- wine-staging
- pavucontrol
- distrobox
- geany
- thunderbird
- ntfs3g
- flatpak
- discord
- kopia
- telegram-desktop
- screen
- nodejs
- pipx
- ncdu
- python311Packages.pip
- caffeine-ng
- php
- adapta-gtk-theme
- mlocate
- yt-dlp
- pamixer
- gthumb
- unzip
- lxrandr
- pinta
- virt-manager
- pantheon-tweaks
- gh
- lazygit

## Shell and Prompt

- ZSH with Oh My Zsh
- Starship prompt
- Shell aliases for common Nix operations (see below)

## Nix ZSH Aliases

These are injected system-wide for the `derrik` user:

- `nrb`: run `sudo nixos-rebuild switch --flake /home/derrik/nixos-config#$(hostname)`
- `nrb-test`: run `sudo nixos-rebuild test --flake /home/derrik/nixos-config#$(hostname)`
- `nrb-boot`: run `sudo nixos-rebuild boot --flake /home/derrik/nixos-config#$(hostname)`
- `nfu`: run `nix flake update --flake /home/derrik/nixos-config`
- `nfu-rebuild`: change to the flake directory, update the flake, then rebuild the system using the hostname detected from `flake.nix`
- `ngc`: run `nix-collect-garbage -d`
- `nix-search`: run `nix search nixpkgs`
- `nix-lint`: run `nix flake check --flake /home/derrik/nixos-config`

## Deployment

On any machine, ensure `/etc/nixos/hardware-configuration.nix` exists from a prior NixOS install, then run:

```bash
sudo ./deploy.sh
```

The repo tracks a generic `hardware-configuration.nix`, but `deploy.sh` overwrites it from `/etc/nixos/hardware-configuration.nix` on each machine before applying the configuration.

## Hermes Agent

Hermes Agent is enabled as a system service with:

- Model default: `stepfun/step-3.7-flash:free`
- All toolsets enabled
- Local terminal backend
- Environment secrets from `/run/secrets/hermes-env`

The `derrik` user is placed in the `hermes` group and the Hermes state directory permissions are managed via `systemd.tmpfiles` so the service and user access survive rebuilds.

## Updating This Config

```bash
cd /home/derrik/nixos-config
git pull
nfu-rebuild
```
