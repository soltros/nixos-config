{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  systemd.user.services.set-plasma-settings = {
    description = "Configure KDE Plasma dark theme, Papirus icons, fonts, and shortcuts";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = with pkgs; [
      kdePackages.kconfig
      coreutils
      dconf
    ];
    script = ''
      KWRITE="${pkgs.kdePackages.kconfig}/bin/kwriteconfig6"

      # 1. Dark Color Scheme & Plasma Theme
      $KWRITE --file kdeglobals --group General --key ColorScheme "BreezeDark"
      $KWRITE --file plasmarc --group Theme --key name "breeze-dark"

      # 2. Papirus-Dark Icons
      $KWRITE --file kdeglobals --group Icons --key Theme "Papirus-Dark"

      # 3. Cursor theme and size
      $KWRITE --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
      $KWRITE --file kcminputrc --group Mouse --key cursorSize 24

      # 4. Fonts
      $KWRITE --file kdeglobals --group General --key font "Inter,9,-1,5,50,0,0,0,0,0"
      $KWRITE --file kdeglobals --group General --key fixed "Roboto Mono,10,-1,5,50,0,0,0,0,0"
      $KWRITE --file kdeglobals --group General --key smallestReadableFont "Inter,8,-1,5,50,0,0,0,0,0"
      $KWRITE --file kdeglobals --group General --key toolBarFont "Inter,9,-1,5,50,0,0,0,0,0"
      $KWRITE --file kdeglobals --group General --key menuFont "Inter,9,-1,5,50,0,0,0,0,0"

      # 5. GTK 3 & 4 dark theme, fonts, and Papirus-Dark icons
      mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
      cat << 'EOF' > "$HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Inter 9
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
      cp -f "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

      /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" || true
      /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Breeze-Dark'" || true
      /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'" || true
      /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/font-name "'Inter 9'" || true
      /run/current-system/sw/bin/dconf write /org/gnome/desktop/interface/monospace-font-name "'Roboto Mono 10'" || true

      # 6. Voxtype Shortcut (Numpad + / KP_Add)
      mkdir -p "$HOME/.local/share/applications"
      cat << 'EOF' > "$HOME/.local/share/applications/voxtype-toggle.desktop"
[Desktop Entry]
Name=Voxtype Toggle Dictation
Exec=voxtype record toggle
Type=Application
Terminal=false
Icon=audio-input-microphone
NoDisplay=true
StartupNotify=false
EOF

      $KWRITE --file kglobalshortcutsrc --group "voxtype-toggle.desktop" --key "_k_friendly_name" "Voxtype Toggle Dictation"
      $KWRITE --file kglobalshortcutsrc --group "voxtype-toggle.desktop" --key "_launch" "KP_Add,none,Voxtype Toggle Dictation"

      # 7. Hermes Agent launcher (dedicated Kitty terminal)
      cat << 'EOF' > "$HOME/.local/share/applications/hermes-agent.desktop"
[Desktop Entry]
Name=Hermes Agent
Comment=Launch Hermes Agent in its own Kitty terminal
Exec=/run/current-system/sw/bin/kitty --class hermes-agent --title "Hermes Agent" --working-directory /data/workspace /run/current-system/sw/bin/hermes
Type=Application
Terminal=false
Icon=utilities-terminal
Categories=Utility;TerminalEmulator;ArtificialIntelligence;
StartupNotify=true
EOF

      $KWRITE --file kglobalshortcutsrc --group "hermes-agent.desktop" --key "_k_friendly_name" "Hermes Agent"
      $KWRITE --file kglobalshortcutsrc --group "hermes-agent.desktop" --key "_launch" "Meta+Alt+H,none,Launch Hermes Agent"
    '';
  };
}
