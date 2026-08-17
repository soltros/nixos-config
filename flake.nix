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
    hostname = "nixos";
  in {
    nixosConfigurations = {
      "${hostname}" = nixpkgs.lib.nixosSystem {
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

            # Enable custom AMD GPU module
            hardware.amd.enable = true;

            # Enable the Pantheon Desktop Environment.
            services.xserver.displayManager.lightdm.enable = true;
            services.desktopManager.pantheon.enable = true;

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
