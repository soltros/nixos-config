{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    usbutils
    pciutils
    xenia
  
    htop
  ];
}
