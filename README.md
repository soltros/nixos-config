# b450m-d3sh NixOS Flake

Desktop configuration for Derrik's AMD desktop. Single host, no laptop references.

# Hardware

- CPU: AMD Ryzen 5 5600X
- GPU: AMD Radeon (amdgpu driver)
- RAM: 32 GB
- Disk: NVMe Btrfs
- Boot: systemd-boot on EFI

# Kernel

- Latest Linux kernel via nixpkgs unstable
- amd_pstate=active for Ryzen power/performance scaling
- mitigations=off for reduced Spectre/Meltdown overhead on a single-user desktop
- transparent_hugepage=never for lower latency

# CPU and power

- cpuFreqGovernor = ondemand
- vm.swappiness = 10
- vm.vfs_cache_pressure = 50
- thermald enabled for thermal management under sustained load

# Graphics

- amdgpu driver with SI/CIK legacy support enabled
- OpenCL via ROCm ICD
- Vulkan via Mesa RADV
- 32-bit graphics support enabled
- GameMode for gaming optimizations

# Desktop

- Budgie desktop environment on Wayland
- LightDM display manager
- Default theme: Adapta GTK and Papirus-Dark icons
- Fonts: Inter, Open Sans, Roboto Mono, Hack, Noto, DejaVu, Fira Code
- Flatpak support enabled

# Audio

- PipeWire with ALSA and PulseAudio compatibility
- 32-bit ALSA support
- rtkit enabled

# Input and automation

- uinput enabled
- ydotool and dotool for input automation
- wtype for Wayland typing
- wl-clipboard for clipboard

# User

- User: derrik
- Shell: ZSH with Oh My Zsh (git, sudo plugins)
- Starship prompt
- Groups: networkmanager, wheel, hermes, input, uinput

# System services

- NetworkManager
- CUPS printing
- thermald
- weekly Btrfs scrub
- Hermes Agent (system-level, container mode)

# Packages

- Antigravity IDE and CLI
- Waterfox
- Steam, Heroic Games Launcher
- Bitwarden, Discord, Signal, Fluffychat, Telegram
- VLC, GIMP, Spotify, LibreOffice
- Git, lazygit, gh
- Python 3.12, pipx, nodejs
- virt-manager, distrobox
- yt-dlp, kopia, caffeine-ng
- wget, ncdu, unzip, lxrandr, pamixer, pavucontrol, gthumb, pinta, screen

# Nix configuration

- experimental features: nix-command, flakes
- auto-optimise-store = true
- allowUnfree = true
- documentation builds disabled

# Aliases

- nrb: nixos-rebuild switch
- nrb-test: nixos-rebuild test
- nrb-boot: nixos-rebuild boot
- nfu: nix flake update
- nfu-rebuild: deploy.sh
- ngc: nix-collect-garbage -d
- nix-search: nix search nixpkgs
- nix-lint: nix flake check

## Budgie branch

Based on `desktop_pantheon`, preserving its hardware and application configuration.
Budgie is the default login session. GNOME Software is enabled alongside Flatpak.
Adapta GTK and Papirus-Dark icons are installed and configured as desktop and
LightDM defaults. Existing per-user theme choices take precedence over desktop
defaults; these settings remain editable in Budgie Desktop Settings.

Validate without rebuilding or activating the system:

```sh
nix flake check --no-build
nix eval --raw .#nixosConfigurations.b450m-d3sh.config.system.build.toplevel.drvPath
```

Desktop parity: merged `master` at `53e4f82` and synchronized dependency pins
with the main checkout's lockfile on 2026-09-17, excluding the removed dictation
input. Hardware, power management, services, and shared modules match master;
Budgie replaces Pantheon. BrowserOS, flakebuilder, and nixboutique inherited
from desktop_pantheon remain available.
