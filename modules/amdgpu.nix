{ config, pkgs, lib, ... }:
with lib;
{
  options.hardware.amd = {
    enable = mkEnableOption "AMD GPU support via the open-source amdgpu or radeon drivers";
  };

  config = mkIf config.hardware.amd.enable {
    # Early kernel module loading
    boot.initrd.kernelModules = [ "amdgpu" ];
    boot.kernelModules = [ "amdgpu" ];
    boot.blacklistedKernelModules = [ "fglrx" ];

    # Enable SI and CIK support
    boot.kernelParams = [ 
      "radeon.si_support=0" 
      "radeon.cik_support=0" 
      "amdgpu.si_support=1" 
      "amdgpu.cik_support=1"
    ];

    # X server configuration
    services.xserver = {
      videoDrivers = [ "amdgpu" ];
    };

    # Graphics and Vulkan configuration (Updated for NixOS Unstable)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;  # For 32-bit applications
      extraPackages = with pkgs; [
        rocmPackages.clr.icd  # OpenCL support
      ];
    };

    # Optional: For Polaris cards (Radeon 500 series) OpenCL support
    environment.variables = {
      ROC_ENABLE_PRE_VEGA = "1";
    };

    # Optional: For testing OpenCL setup
    environment.systemPackages = with pkgs; [
      clinfo
    ];
  };
}
