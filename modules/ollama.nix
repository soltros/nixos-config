{ config, pkgs, lib, ... }:

{
  # Ollama daemon system service with AMD ROCm GPU acceleration
  # Official NixOS Wiki: https://wiki.nixos.org/wiki/Ollama
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    # AMD Radeon RX 6700 XT (Navi 22 / 12 GB VRAM) target is gfx1031.
    # ROCm requires overriding GFX target version to 10.3.0 for gfx1031 support.
    rocmOverrideGfx = "10.3.0";
  };

  # Set HSA_OVERRIDE_GFX_VERSION in session environment for manual CLI / tool runs
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
  };

  # Alpaca - GTK4/Adwaita desktop client for Ollama
  environment.systemPackages = with pkgs; [
    alpaca
  ];
}
