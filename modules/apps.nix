{ pkgs, ... }:
# nixpkger: begin soltros source
let
  soltros = (builtins.getFlake "github:soltros/soltros_nixpkgs/3a7220623c513d65d86fee90bdd00ffea9273b33?narHash=sha256-tGxPCKZebzMGm6Z6TA%2Fk%2FZBvMeXO3V5%2FTfWtbcSReOk%3D").packages.${pkgs.stdenv.hostPlatform.system};
in
# nixpkger: end soltros source

{
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    xenia
  
    htop
  
    brave
    recomplauncher 
    openscad
  
    retroarch
  
    rpcs3
  
    qbittorrent
  
    codex
  
    soltros.lichii
  
    xemu
  ];
}
