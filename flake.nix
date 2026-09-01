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
      services.logind.settings.Login = {
        IdleAction = "ignore";
        HandleHibernateKey = "ignore";
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleSuspendKey = "ignore";
      };
      systemd.sleep.settings.Sleep = {
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspend = "no";
        AllowSuspendThenHibernate = "no";
      };
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

      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.desktopManager.plasma6.enable = true;

      systemd.user.services.set-plasma-settings = {
        description = "Configure KDE Plasma dark theme, Papirus icons, fonts, and shortcuts";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        path = with pkgs; [
          kdePackages.kconfig
          coreutils
          dconf
        ];
        script = ''
          KWRITE="${pkgs.kdePackages.kconfig}/bin/kwriteconfig6"

          # 1. Dark Color Scheme & Plasma Theme
          $KWRITE --file kdeglobals --group General --key ColorScheme "BreezeDark"
          $KWRITE --file plasmarc --group Theme --key name "breeze-dark"

          # 2. Papirus-Dark Icons
          $KWRITE --file kdeglobals --group Icons --key Theme "Papirus-Dark"

          # 3. Cursor theme and size
          $KWRITE --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
          $KWRITE --file kcminputrc --group Mouse --key cursorSize 24

          # 4. Fonts
          $KWRITE --file kdeglobals --group General --key font "Inter,9,-1,5,50,0,0,0,0,0"
          $KWRITE --file kdeglobals --group General --key fixed "Roboto Mono,10,-1,5,50,0,0,0,0,0"
          $KWRITE --file kdeglobals --group General --key smallestReadableFont "Inter,8,-1,5,50,0,0,0,0,0"
          $KWRITE --file kdeglobals --group General --key toolBarFont "Inter,9,-1,5,50,0,0,0,0,0"
          $KWRITE --file kdeglobals --group General --key menuFont "Inter,9,-1,5,50,0,0,0,0,0"

          # 5. GTK 3 & 4 dark theme, fonts, and Papirus-Dark icons
          mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
          cat << 'EOF' > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Inter 9
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
          cp -f "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" || true
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Breeze-Dark'" || true
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'" || true
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/font-name "'Inter 9'" || true
          /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/monospace-font-name "'Roboto Mono 10'" || true

          # 6. Voxtype Shortcut (Numpad + / KP_Add)
          mkdir -p "$HOME/.local/share/applications"
          cat << 'EOF' > "$HOME/.local/share/applications/voxtype-toggle.desktop"
[Desktop Entry]
Name=Voxtype Toggle Dictation
Exec=voxtype record toggle
Type=Application
Terminal=false
Icon=audio-input-microphone
NoDisplay=true
StartupNotify=false
EOF

          $KWRITE --file kglobalshortcutsrc --group "voxtype-toggle.desktop" --key "_k_friendly_name" "Voxtype Toggle Dictation"
          $KWRITE --file kglobalshortcutsrc --group "voxtype-toggle.desktop" --key "_launch" "KP_Add,none,Voxtype Toggle Dictation"
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
          model.provider = "openai-codex";
          model.default = "gpt-5.5";
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
        "A+ /var/lib/hermes - - - - user:derrik:rwx,default:user:derrik:rwx,group:hermes:rwx,default:group:hermes:rwx,mask::rwx,default:mask::rwx"
        "d /home/derrik/.hermes 0700 derrik users -"
        "Z /home/derrik/.hermes 0700 derrik users -"
        "f /var/lib/hermes/.hermes/.env 0660 hermes hermes -"
        "z /var/lib/hermes/.hermes/auth.json 0660 hermes hermes -"
        "A+ /var/lib/hermes/.hermes/auth.json - - - - user:derrik:rw-,group:hermes:rw-,mask::rw-"
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
