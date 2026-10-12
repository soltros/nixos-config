{ config, pkgs, ... }:
# nixpkger: begin soltros source
let
  soltros = (builtins.getFlake "github:soltros/soltros_nixpkgs/3e9d6df6ee348fdc4d06dc913a78c733703b9522?narHash=sha256-LrPvHaV4RHpseT3Es88uz1YIfGHNr%2FLifj%2B7rdEuajU%3D").packages.${pkgs.stdenv.hostPlatform.system};
in
# nixpkger: end soltros source

{
  environment.systemPackages = with pkgs; [

  
    soltros.sharpemu
  
    usbutils
  ];
}
