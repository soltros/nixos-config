{ config, pkgs, ... }:

{
  # Add any permitted insecure packages here as you need them
  # Example: "electron-25.9.0"
  nixpkgs.config.permittedInsecurePackages = [
    
  ];
}
