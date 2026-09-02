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

## Laptop Features (`i3-1315u`)

In addition to the shared configuration, the laptop host enables the following
features:

### Storage
- **Btrfs compression** — `compress=zstd:1` is enabled on `/`, `/home`, and `/nix`.
  This reduces disk usage and improves I/O throughput on the 256 GB NVMe with
  minimal CPU overhead.
- **SSD optimizations** — `ssd` and `discard=async` mount options enable
  TRIM garbage collection without blocking writes.
- **noatime** — disables last-access timestamp updates to reduce write volume
  and improve performance.
- **Btrfs auto-scrub** — a monthly `btrfs scrub` runs on `/` to detect and
  self-heal silent data corruption.

### Graphics & Video Acceleration
- **i915 kernel driver** — FBC (framebuffer compression), GuC firmware
  submission, HuC media decode, Panel Self-Refresh (PSR), and Display Power
  Saving (DC) are enabled via kernel parameters.
- **VA-API** — `intel-media-driver` (iHD backend) for hardware-accelerated
  video decode in Firefox, VLC, and other apps. Verified with `vainfo`.
- **Quick Sync Video (QSV)** — `vpl-gpu-rt` provides Intel VPL runtime for
  hardware-accelerated transcode in ffmpeg and OBS.
- **Vulkan** — `vulkan-loader` + Mesa drivers for Intel integrated graphics.
- **Tools** — `intel-gpu-tools` and `libva-utils` for diagnostics and tuning.

### Audio
- **SOF firmware** — `sof-firmware` is installed for the Intel Smart Sound DSP
  on Raptor Lake-U. This allows the kernel's SOF stack to load codec firmware
  at boot, which is required for reliable audio on this generation.
- **ALSA persistence** — mixer state is saved at shutdown and restored on boot
  so volume levels survive reboots.

### Power Management
- **CPU frequency** — `schedutil` governor is used with Intel P-state for
  responsive frequency scaling that balances performance and power.
- **powertop** — installed for diagnosing power consumption and applying tuning
  suggestions.
- **ZRAM swap** — 50% of RAM is allocated as a compressed block device in
  memory (`zram0`). This is significantly faster than swapping to NVMe under
  memory pressure. The existing swap partition remains as a last-resort
  overflow.
- **systemd-oomd** — enabled as a userspace OOM killer. When zram is full the
  kernel's native OOM killer can fail to trigger; `oomd` handles this case by
  terminating the largest memory consumers before the system locks up.
- **NetworkManager wait-online disabled** — `NetworkManager-wait-online.service`
  is disabled to avoid a ~4.6 s boot delay when no network is immediately
  available.

### Firmware & Microcode
- **Intel microcode** — `updateMicrocode = true` ensures the CPU receives
  microcode patches at every boot, patching silicon-level bugs and security
  vulnerabilities.
- **Redistributable firmware** — `enableRedistributableFirmware` is enabled so
  that NixOS can ship binary firmware blobs required by the GPU, WiFi, and NVMe
  controller.

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

Hermes Agent is enabled as a native system service with:

- Model default: `stepfun/step-3.7-flash:free`
- All toolsets enabled
- Local terminal backend
- Environment secrets from `/run/secrets/hermes-env`

Hermes uses `/var/lib/hermes/.hermes` for state. The `derrik` account belongs to
the `hermes` group, and `auth.json` is group-readable and writable so the native
service and interactive CLI can share credentials.

## Updating This Config

```bash
cd /home/derrik/nixos-config
git pull
nfu-rebuild
```
