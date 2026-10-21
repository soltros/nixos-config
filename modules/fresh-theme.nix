{ config, lib, pkgs, ... }:

{
  # Install as the user so Fresh can continue to save its own settings.
  system.activationScripts.fresh-theme = {
    deps = [ "users" ];
    text = ''
      ${pkgs.util-linux}/bin/runuser -u derrik -- \
        ${pkgs.python3}/bin/python3 ${./fresh/configure.py} \
        ${lib.escapeShellArg config.users.users.derrik.home} \
        ${./fresh/catppuccin-mocha.json}
    '';
  };
}
