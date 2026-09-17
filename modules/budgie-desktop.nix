{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        theme = {
          name = "Adapta";
          package = pkgs.adapta-gtk-theme;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };
    };
  };
  services.desktopManager.budgie.enable = true;
  services.displayManager.defaultSession = "budgie-desktop";

  services.gnome.gnome-software.enable = true;

  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
    papirus-icon-theme
  ];

  # Defaults remain changeable in Budgie Desktop Settings.
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Adapta";
        icon-theme = "Papirus-Dark";
      };
      "org/gnome/desktop/wm/preferences".theme = "Adapta";
      "com/solus-project/budgie-panel".builtin-theme = false;
    };
  }];
}
