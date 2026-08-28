{ config, pkgs, ... }:

{
  # SOF (Sound Open Firmware) for Intel Smart Sound DSP on Raptor Lake-U.
  # Without this the i3-1315U's built-in audio DSP can fail to initialize
  # because the codec firmware is loaded through SOF rather than HDA-Intel.
  hardware.firmware = with pkgs; [
    sof-firmware
  ];
}
