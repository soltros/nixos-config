{ config, pkgs, ... }:

{
  # Enable OpenSSH daemon
  services.openssh.enable = true;

  # Configure GnuPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
