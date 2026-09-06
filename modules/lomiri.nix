{ pkgs, ... }:

{
  services.desktopManager.lomiri.enable = true;
  services.displayManager.defaultSession = "lomiri";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };
}
