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

- Pantheon desktop environment on Wayland
- LightDM display manager
- Custom dock favorites via dconf
- Custom theme: Papirus-Dark icons, Blueberry GTK, elementary cursor
- Fonts: Inter, Open Sans, Roboto Mono, Hack, Noto, DejaVu, Fira Code
- Flatpak support enabled
- Custom keybinding: Voxtype dictation toggle on KP_Add
- Voxtype installed (Vulkan + OSD GTK4)

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
- Voxtype (Vulkan + OSD GTK4)
- Firefox
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
