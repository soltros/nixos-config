{ config, pkgs, ... }: 

{
  imports = [ ./fresh-theme.nix ];

  # Fresh's onig_sys crate needs the system Oniguruma library during builds.
  nixpkgs.overlays = [
    (final: prev: {
      # Build the crate's matching AWS-LC source: nixpkgs' system package
      # uses a different header layout and symbol namespace.
      codex = prev.codex.overrideAttrs (old: {
        env = builtins.removeAttrs (old.env or { }) [
          "AWS_LC_SYS_SYSTEM_DIR"
          "AWS_LC_SYS_SYSTEM_BINDINGS"
        ] // {
          AWS_LC_SYS_USE_SYSTEM = "0";
        };
        # cargoUseSystemLibs resets this to 1 during preConfigure.
        # Override it after that hook, immediately before Cargo runs.
        preBuild = (old.preBuild or "") + ''
          export AWS_LC_SYS_USE_SYSTEM=0
          unset AWS_LC_SYS_SYSTEM_DIR AWS_LC_SYS_SYSTEM_BINDINGS
        '';
      });
      fresh-editor = prev.fresh-editor.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ final.oniguruma ];
      });
    })
  ];

  # Add packages to the system environment
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    git
    runelite
    fresh-editor
    nixpkger
    bolt-launcher
    cargo
    mpv
    python312
    btrfs-progs
    pkgs.kdePackages.partitionmanager
    papirus-icon-theme
    libreoffice-qt
    spotify
    tailscale
    vlc
    gimp
    wget
    zettlr
    winetricks
    wine64
    fresh-editor
    #wine-staging
    pavucontrol
    distrobox
    geany
    thunderbird
    ntfs3g
    flatpak
    discord
    kopia
    telegram-desktop
    screen
    nodejs
    pipx
    ncdu
    python311Packages.pip
    caffeine-ng
    php
    adapta-gtk-theme
    mlocate
    yt-dlp
    pamixer
    gthumb
    unzip
    lxrandr
    pinta
    virt-manager
    gh
    lazygit
    kitty
  ];
}
