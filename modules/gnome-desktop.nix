{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.defaultSession = "gnome";

  services.gnome.gnome-software.enable = true;

  environment.systemPackages = [ pkgs.papirus-icon-theme ];

  # Desktop defaults remain changeable in GNOME Settings and Tweaks.
  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface" = {
      icon-theme = "Papirus-Dark";
    };
  }];
}
