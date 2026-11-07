{ pkgs, ... }:

{
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = appimagePkgs: [
        appimagePkgs.libgpg-error
      ];
    };
  };
}
