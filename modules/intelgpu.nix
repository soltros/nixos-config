{ config, pkgs, lib, ... }:

with lib;

{
  options.hardware.intel = {
    enable = mkEnableOption "Intel GPU support via the i915 driver for optimal performance and feature set";
  };

  config = mkIf config.hardware.intel.enable {
    # i915 is built into the kernel on modern kernels; ordering only.
    boot.kernelModules = [ "kvm-intel" ];
    boot.kernelParams = [
      "i915.enable_fbc=1"         # Framebuffer compression — saves VRAM + power
      "i915.enable_guc=3"         # GuC command submission + HuC media decode firmware
      "i915.enable_psr=1"         # Panel Self-Refresh — idle display power savings
      "i915.enable_dc=1"          # Display Power Saving for eDP panels
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # VA-API userspace driver for Broadwell (2014) and newer — covers Raptor Lake
        intel-media-driver
        libva
        libva-utils
        # Quick Sync Video (QSV) runtime — Tiger Lake (2020) and newer
        vpl-gpu-rt
        # Vulkan ICD for Intel
        vulkan-loader
        # i915 user-space tools
        intel-gpu-tools
      ];
    };

    services.xserver.videoDrivers = [ "modesetting" ];

    # Prefer the modern iHD VA-API backend (required for intel-media-driver)
    environment.variables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
