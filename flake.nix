{
  description = "NixOS system flake for derrik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    voxtype = {
      url = "github:peteonrails/voxtype/v0.7.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    unity-on-nix = {
      url = "github:soltros/unity-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unity-on-nix, hermes-agent, antigravity-nix, voxtype, ... }@inputs: 
  let
    shared = { config, pkgs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.auto-optimise-store = true;

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      
      # Use the latest Linux kernel
      boot.kernelPackages = pkgs.linuxPackages_latest;

      # Required for VA-API/QSV init on modern Intel iGPUs (per NixOS wiki)
      hardware.enableRedistributableFirmware = true;

      # Fix microcode: hardware-configuration.nix sets this, but we pin it true here
      hardware.cpu.intel.updateMicrocode = true;

      # Persist ALSA mixer state across reboots (per NixOS ALSA wiki)
      hardware.alsa.enablePersistence = true;

      # Power management for laptops
      powerManagement = {
        enable = true;
        cpuFreqGovernor = "schedutil";  # Intel P-state + schedutil = good balance
        powertop.enable = true;
      };

      # ZRAM compressed swap — much faster than NVMe swap under memory pressure
      # Size: 50% of RAM. On 8 GiB that's 4 GiB. In-place compress, no disk I/O.
      # WARNING per NixOS wiki: when using zram, also enable systemd-oomd, because
      # zram's hard capacity limit can prevent the kernel's OOM killer from firing.
      zramSwap = {
        enable = true;
        memoryPercent = 50;
      };
      systemd.oomd.enable = true;

      # Keep the existing swap partition as a last-resort overflow (optional,
      # but harmless with zram in front of it). It's already declared in
      # hardware-configuration.nix.

      networking.networkmanager.enable = true;

      time.timeZone = "America/Detroit";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      # Fonts configuration
      fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
          inter
          open-sans
          roboto
          roboto-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          dejavu_fonts
          liberation_ttf
          hack-font
          fira-code
          font-awesome
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
            serif = [ "Noto Serif" "DejaVu Serif" ];
            monospace = [ "Roboto Mono" "Hack" "DejaVu Sans Mono" ];
            emoji = [ "Noto Color Emoji" ];
          };
          subpixel.rgba = "rgb";
          hinting.style = "slight";
        };
      };

      # Enable Flatpak support
      services.flatpak.enable = true;
      xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      environment.sessionVariables.PATH = [ "/home/derrik/.cargo/bin" ];

      # Enable Hermes Agent
      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        container.enable = false;
        settings = {
          model.provider = "openai-codex";
          model.default = "gpt-5.5";
          toolsets = [ "all" "skills" ];
          terminal = {
            backend = "local";
            timeout = 180;
          };
        };
        environmentFiles = [ "/run/secrets/hermes-env" ];
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # Hardware and uinput for typing emulation / voxtype
      hardware.uinput.enable = true;
      programs.ydotool.enable = true;

      boot.kernel.sysctl = {
        "vm.vfs_cache_pressure" = 50;
        "vm.swappiness" = 10;
      };

      # services.thermald.enable = true;

      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
      };

      # Define a user account.
      users.users."derrik" = {
        isNormalUser = true;
        description = "Derrik Diener";
        extraGroups = [ "networkmanager" "wheel" "hermes" "input" "uinput" ];
        shell = pkgs.zsh;
        packages = [];
      };

      systemd.tmpfiles.rules = [
        # The module keeps auth.json private by default; permit interactive
        # members of the hermes group to use the shared CLI credentials.
        "z /var/lib/hermes/.hermes/auth.json 0660 hermes hermes -"
        "d /data/workspace 0755 derrik users -"
      ];

      # Install firefox.
      programs.firefox.enable = true;

      # Setup ZSH and Starship
      programs.zsh = {
        enable = true;
        shellAliases = {
          nrb = "sudo nixos-rebuild switch --flake /home/derrik/nixos-config#$(cat /etc/hostname)";
          nrb-test = "sudo nixos-rebuild test --flake /home/derrik/nixos-config#$(cat /etc/hostname)";
          nrb-boot = "sudo nixos-rebuild boot --flake /home/derrik/nixos-config#$(cat /etc/hostname)";
          nfu = "sudo nix flake update --flake /home/derrik/nixos-config";
          nfu-rebuild = "cd /home/derrik/nixos-config && sudo ./deploy.sh";
          ngc = "sudo nix-collect-garbage -d";
          nix-search = "nix search nixpkgs";
          nix-lint = "nix flake check --flake /home/derrik/nixos-config";
        };
        autosuggestions.enable = true;
        ohMyZsh = {
          enable = true;
          plugins = [ "git" "sudo" ];
        };
      };
      programs.starship.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        (final: prev: {
          chatgpt = prev.callPackage ./pkgs/chatgpt.nix {};
          pipx = prev.pipx.overridePythonAttrs (_: { doCheck = false; });
        })
      ];

      environment.systemPackages = with pkgs; [
        chatgpt
        antigravity-nix.packages.x86_64-linux.default
        antigravity-nix.packages.x86_64-linux.google-antigravity-ide
        antigravity-nix.packages.x86_64-linux.google-antigravity-cli
        voxtype.packages.x86_64-linux.vulkan
        voxtype.packages.x86_64-linux.osd-gtk4
        wtype
        wl-clipboard
        ydotool
        dotool
        papirus-icon-theme
        zsh-autosuggestions
        codex
        bubblewrap # required for Muse sandbox (bwrap)
      ];

      # Disable package documentation builds to bypass known unstable python3.12-doc bugs
      documentation.enable = false;

      system.stateVersion = "26.05";
    };
  in {
    packages.x86_64-linux = rec {
      chatgpt = (import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      }).callPackage ./pkgs/chatgpt.nix {};
      default = chatgpt;
    };

    nixosConfigurations = {
      "b450m-d3sh" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          hermes-agent.nixosModules.default
          unity-on-nix.nixosModules.default
          ./modules/unity-desktop.nix
          ./modules/amdgpu.nix
          ./modules/derriks-apps.nix
          ./modules/durandal-hermes-skin.nix
          ./modules/gamemode.nix
          ./modules/steam.nix
          ./modules/tailscale-support.nix
          ./modules/unsecure-packages.nix
          ./modules/ssh-server.nix
          ./modules/virtualization-support.nix
          ./modules/muse-code.nix
          ./hardware-configuration.nix
          shared
          ({ config, pkgs, ... }: {
            networking.hostName = "b450m-d3sh";
            hardware.amd.enable = true;
          })
        ];
      };
      "i3-1315u" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          hermes-agent.nixosModules.default
          unity-on-nix.nixosModules.default
          ./modules/unity-desktop.nix
          ./modules/amdgpu.nix
          ./modules/intelgpu.nix
          ./modules/intel-firmware.nix
          ./modules/derriks-apps.nix
          ./modules/durandal-hermes-skin.nix
          ./modules/gamemode.nix
          ./modules/steam.nix
          ./modules/tailscale-support.nix
          ./modules/unsecure-packages.nix
          ./modules/ssh-server.nix
          ./modules/virtualization-support.nix
          ./modules/muse-code.nix
          ./hardware-configuration.nix
          shared
          ({ config, pkgs, ... }: {
            networking.hostName = "i3-1315u";
            hardware.amd.enable = false;
            hardware.intel.enable = true;
            services.jackett.enable = true;
          })
        ];
      };
    };
  };
}
