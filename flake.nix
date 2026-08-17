{
  description = "NixOS system flake for derrik";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hermes-agent, antigravity-nix, ... }@inputs: 
  let
    # Change your hostname here!
    hostname = "b450m-d3sh";
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          hermes-agent.nixosModules.default
          ./modules/amdgpu.nix
          ./modules/intelgpu.nix
          ./modules/derriks-apps.nix
          ./modules/gamemode.nix
          ./modules/steam.nix
          ./modules/tailscale-support.nix
          ./modules/unsecure-packages.nix
          ./modules/ssh-server.nix
          ./modules/virtualization-support.nix
          ./hardware-configuration.nix
          ({ config, pkgs, ... }: {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            # Bootloader.
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            
            # Use the latest Linux kernel
            boot.kernelPackages = pkgs.linuxPackages_latest;

            networking.hostName = hostname;
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

            # Enable the X11 windowing system.
            services.xserver.enable = true;

            # Conditional GPU configuration by hostname
            hardware.amd.enable = (hostname == "b450m-d3sh");
            hardware.intel.enable = (hostname == "13-1315u");

            # Enable the Pantheon Desktop Environment.
            services.xserver.displayManager.lightdm.enable = true;
            services.desktopManager.pantheon.enable = true;

            # Dock favorites via user dconf
            systemd.user.services.set-dock-favorites = {
              description = "Set Pantheon dock favorites";
              wantedBy = [ "graphical-session.target" ];
              serviceConfig.Type = "oneshot";
              serviceConfig.RemainAfterExit = true;
              script = ''
                dconf write /io/elementary/dock/launchers "['firefox.desktop', 'thunderbird.desktop', 'discord.desktop', 'org.signal.Signal.desktop', 'im.fluffychat.Fluffychat.desktop', 'io.github.victoralvesf.aonsoku.desktop', 'steam.desktop', 'com.heroicgameslauncher.hgl.desktop', 'geany.desktop', 'io.elementary.code.desktop', 'Zettlr.desktop', 'io.elementary.files.desktop', 'io.elementary.terminal.desktop']"
              '';
            };

            # Enable Flatpak support
            services.flatpak.enable = true;

            # Enable Hermes Agent
            services.hermes-agent = {
              enable = true;
              addToSystemPackages = true;
              container.enable = true;
              settings = {
                model.default = "stepfun/step-3.7-flash:free";
                toolsets = [ "all" ];
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

            # Define a user account.
            users.users."derrik" = {
              isNormalUser = true;
              description = "Derrik Diener";
              extraGroups = [ "networkmanager" "wheel" "hermes" ];
              shell = pkgs.zsh;
              packages = with pkgs; [];
            };

            # Ensure Hermes state directory group is accessible
            systemd.tmpfiles.rules = [
              "d /var/lib/hermes/.hermes 0770 hermes hermes -"
              "f /var/lib/hermes/.hermes/.env 0660 hermes hermes -"
            ];

            # Install firefox.
            programs.firefox.enable = true;

            # Setup ZSH and Starship
            programs.zsh = {
              enable = true;
              shellAliases = {
                nrb = "sudo nixos-rebuild switch --flake .#\$(cat /etc/hostname)";
                nrb-test = "sudo nixos-rebuild test --flake .#\$(cat /etc/hostname)";
                nrb-boot = "sudo nixos-rebuild boot --flake .#\$(cat /etc/hostname)";
                nfu = "nix flake update --flake /home/derrik/nixos-config";
                nfu-rebuild = "cd /home/derrik/nixos-config && sudo ./deploy.sh";
                ngc = "nix-collect-garbage -d";
                nix-search = "nix search nixpkgs";
                nix-lint = "nix flake check --flake /home/derrik/nixos-config";
              };
              ohMyZsh = {
                enable = true;
                plugins = [ "git" "sudo" ];
              };
            };
            programs.starship.enable = true;

            # Allow unfree packages
            nixpkgs.config.allowUnfree = true;

            environment.systemPackages = with pkgs; [
              antigravity-nix.packages.x86_64-linux.default
              antigravity-nix.packages.x86_64-linux.google-antigravity-ide
              antigravity-nix.packages.x86_64-linux.google-antigravity-cli
            ];

            # Disable package documentation builds to bypass known unstable python3.12-doc bugs
            documentation.doc.enable = false;

            system.stateVersion = "26.05";
          })
        ];
      };
    };
  };
}
