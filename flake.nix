{
  description = "NixOS system flake for derrik";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    voxtype = {
      url = "github:peteonrails/voxtype/v0.7.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hermes-agent, antigravity-nix, voxtype, ... }@inputs:
  let
    shared = { config, pkgs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.auto-optimise-store = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.kernelParams = [
        "amd_pstate=active"
        "transparent_hugepage=never"
        "usbcore.autosuspend=-1"
      ];

      powerManagement.cpuFreqGovernor = "performance";

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

      services.xserver.enable = true;
      services.xserver.displayManager.lightdm.enable = true;
      services.desktopManager.pantheon.enable = true;

      systemd.user.services.set-dock-favorites = {
        description = "Set Pantheon dock favorites";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          /run/current-system/sw/bin/dconf write /io/elementary/dock/launchers "['firefox.desktop', 'thunderbird.desktop', 'discord.desktop', 'org.signal.Signal.desktop', 'im.fluffychat.Fluffychat.desktop', 'io.github.victoralvesf.aonsoku.desktop', 'steam.desktop', 'com.heroicgameslauncher.hgl.desktop', 'geany.desktop', 'io.elementary.code.desktop', 'Zettlr.desktop', 'io.elementary.files.desktop', 'io.elementary.terminal.desktop']"
        '';
      };

      systemd.user.services.set-pantheon-theme = {
        description = "Set Pantheon theme, cursor, and fonts";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        script = ''
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'elementary'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/cursor-size 24
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/font-name "'Inter 9'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/document-font-name "'Open Sans 10'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/monospace-font-name "'Roboto Mono 10'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'io.elementary.stylesheet.blueberry'"
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/sound/theme-name "'elementary'"
          /run/current-system/sw/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/']"
          /run/current-system/sw/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/name "'Voxtype Toggle Dictation'"
          /run/current-system/sw/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/command "'voxtype record toggle'"
          /run/current-system/sw/bin/dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/binding "'KP_Add'"
        '';
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

      services.flatpak.enable = true;

      environment.sessionVariables.PATH = [ "/home/derrik/.cargo/bin" ];

      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        container.enable = true;
        settings = {
          model.provider = "meta-ai";
          model.default = "muse-spark-1.2";
          model.base_url = null;
          model.api_mode = null;
          model.lmstudio_load_mode = null;
          model.context_length = null;
          toolsets = [ "all" ];
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
        "d /var/lib/hermes 2770 hermes hermes -"
        "d /var/lib/hermes/.hermes 2770 hermes hermes -"
        "Z /var/lib/hermes 2770 hermes hermes -"
        "A+ /var/lib/hermes - - - - default:group:hermes:rwx,group:hermes:rwx,default:mask::rwx"
        "d /home/derrik/.hermes 0700 derrik users -"
        "Z /home/derrik/.hermes 0700 derrik users -"
        "f /var/lib/hermes/.hermes/.env 0660 hermes hermes -"
        "d /data/workspace 0755 derrik users -"
      ];

      programs.firefox.enable = true;

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

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
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
          ./modules/derriks-apps.nix
          ./modules/gamemode.nix
          ./modules/steam.nix
          ./modules/tailscale-support.nix
          ./modules/unsecure-packages.nix
          ./modules/ssh-server.nix
          ./modules/virtualization-support.nix
          ./modules/muse-code.nix
          ./modules/ollama.nix
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
