{ config, pkgs, ... }:

{
  # Docker and Compose for local application testing.
  virtualisation.docker.enable = true;
  users.users.derrik.extraGroups = [ "docker" ];
  environment.systemPackages = [ pkgs.docker-compose ];

  # VirtualBox support
  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "vboxdrv.load_state=1" ];
  boot.kernelModules = [ "vboxdrv" "vboxnetadp" "vboxnetflt" "vboxpci" ];
  users.extraGroups.vboxusers.members = [ "derrik" ];
  
  # Virtualization support
  virtualisation.libvirtd.enable = true;

}
