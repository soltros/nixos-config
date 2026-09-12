{
  description = "NixOS system flake for derrik";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    soltros-nixpkgs = {
      url = "github:soltros/soltros_nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    voxtype = {
      url = "github:peteonrails/voxtype/v0.7.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browseros-ai = {
      url = "github:Hill-Brandon-M/browseros-ai";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hermes-agent, antigravity-nix, voxtype, browseros-ai, ... }@inputs:
  let
    shared = { config, pkgs, ... }:
    let
      browserosVersion = "0.44.0.1";
      browserosSrc = pkgs.fetchurl {
        url = "https://github.com/browseros-ai/BrowserOS/releases/download/v${browserosVersion}/BrowserOS_v${browserosVersion}_x64.AppImage";
        hash = "sha256-ALnyVMnexYy48br9qbWaEbOZm7hJR9g39a9nYzbWXwo=";
      };
      browserosContents = pkgs.appimageTools.extract {
        pname = "browseros";
        version = browserosVersion;
        src = browserosSrc;
      };
      browseros = pkgs.appimageTools.wrapType2 {
        pname = "browseros";
        version = browserosVersion;
        src = browserosSrc;
        extraInstallCommands = ''
          install -m 444 -D ${browserosContents}/browseros.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/browseros.desktop \
            --replace 'Exec=AppRun' 'Exec=browseros'
          cp -r ${browserosContents}/usr/share/icons $out/share
        '';
        meta = {
          description = "Open-source agentic AI web browser";
          homepage = "https://browseros.com/";
          downloadPage = "https://github.com/browseros-ai/BrowserOS/releases";
          license = pkgs.lib.licenses.agpl3Only;
          sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
          platforms = [ "x86_64-linux" ];
          mainProgram = "browseros";
        };
      };
    in {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.auto-optimise-store = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.kernelParams = [
        "amd_pstate=active"
        "pcie_aspm=off"
        "transparent_hugepage=never"
        "usbcore.autosuspend=-1"
      ];

      # Desktop: favor stability/performance over power saving. In particular,
      # keep USB devices/controllers out of runtime autosuspend and prevent the
      # machine from entering sleep states that reset the xHCI controller.
      powerManagement = {
        enable = true;
        cpuFreqGovernor = "performance";
        powertop.enable = false;
      };
      services.power-profiles-daemon.enable = false;
      services.udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        ACTION=="add|change", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="on"
      '';

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
          nerd-fonts.symbols-only
        ];
        fontconfig = {
          enable = true;
          defaultFonts = {
            sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
            serif = [ "Noto Serif" "DejaVu Serif" ];
            monospace = [ "Roboto Mono" "Symbols Nerd Font" "Hack" "DejaVu Sans Mono" ];
            emoji = [ "Noto Color Emoji" ];
          };
          subpixel.rgba = "rgb";
          hinting.style = "slight";
        };
      };

      services.flatpak.enable = true;

      environment.sessionVariables.PATH = [ "/home/derrik/.cargo/bin" ];

      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        container.enable = false;
        settings = {
          model.provider = "openai-codex";
          model.default = "gpt-5.4-mini";
          toolsets = [ "all" "skills" ];
          terminal = {
            backend = "local";
            timeout = 180;
          };
        };
        environmentFiles = [ "/run/secrets/hermes-env" ];
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      services.printing.enable = true;

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

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

      users.users."derrik" = {
        isNormalUser = true;
        description = "Derrik Diener";
        extraGroups = [ "networkmanager" "wheel" "hermes" "input" "uinput" "video" "render" ];
        shell = pkgs.zsh;
        packages = [];
      };

      systemd.tmpfiles.rules = [
        # The module keeps auth.json private by default; permit interactive
        # members of the hermes group to use the shared CLI credentials.
        "z /var/lib/hermes/.hermes/auth.json 0660 hermes hermes -"
        "d /data/workspace 0755 derrik users -"
      ];


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
          # Replacements for common utilities
          cat = "bat --paging=never";
          grep = "rg";
          find = "fd";
          df = "duf";
          ls = "eza --icons=auto";
          ll = "eza -la --icons=auto --git";
          tree = "eza --tree --icons=auto";
        };
        autosuggestions.enable = true;
        ohMyZsh = {
          enable = true;
          plugins = [ "git" "sudo" ];
        };
      };
      programs.starship.enable = true;

      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        inputs.soltros-nixpkgs.overlays.default
      ];

      environment.systemPackages = with pkgs; [
        chatgpt
        eza
        bat
        ripgrep
        fd
        duf
	flakebuilder
        waterfox
        browseros
	nixboutique
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
        # lmstudio # removed for Hermes OpenCode setup
      ];

      documentation.doc.enable = false;

      system.stateVersion = "26.05";
    };
  in {
    nixosConfigurations = {
      "b450m-d3sh" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          hermes-agent.nixosModules.default
          ./modules/amdgpu.nix
          ./modules/apps.nix
          ./modules/pantheon-desktop.nix
          ./modules/plymouth-theme.nix
          ./modules/derriks-apps.nix
          ./modules/durandal-hermes-skin.nix
          ./modules/gamemode.nix
          ./modules/hermes-codex-profiles.nix
          ./modules/hermes-runtime-compat.nix
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
    };
  };
}
