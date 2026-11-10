{ config, pkgs, ... }: 

{
  imports = [ ./fresh-theme.nix ];

  # Fresh's onig_sys crate needs the system Oniguruma library during builds.
  nixpkgs.overlays = [
    (final: prev: {
      # aws-lc-sys must use AWS-LC, not the separate OpenSSL dependency.
      codex = prev.codex.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ final.aws-lc ];
        env = (old.env or { }) // {
          AWS_LC_SYS_USE_SYSTEM = "1";
          # The crate expects include/ and lib/ under one prefix.
          AWS_LC_SYS_SYSTEM_DIR = final.symlinkJoin {
            name = "codex-aws-lc";
            paths = [
              (final.lib.getDev final.aws-lc)
              (final.lib.getLib final.aws-lc)
            ];
          };
        };
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
