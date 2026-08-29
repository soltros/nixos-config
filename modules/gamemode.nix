{ config, pkgs, ... }:

{
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
      };
    };
  };
}
