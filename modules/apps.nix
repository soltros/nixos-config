{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    xenia
  
    htop
  
    brave
  
    openscad
  
    retroarch
  
    rpcs3
  
    qbittorrent
  ];
}
