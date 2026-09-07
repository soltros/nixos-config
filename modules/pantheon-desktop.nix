{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
  };

  services.desktopManager.pantheon = {
    enable = true;
    extraSwitchboardPlugs = [ pkgs.pantheon-tweaks ];
  };

  environment.systemPackages = with pkgs; [
    pantheon-tweaks
    papirus-icon-theme
  ];
}
