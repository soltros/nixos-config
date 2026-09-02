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

      # 7. Durandal / Hermes Agent launcher (dedicated Marathon-styled Kitty terminal)
      mkdir -p "$HOME/.local/bin" "$HOME/.config/kitty" "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/scalable/apps"

      cat << 'EOF' > "$HOME/.local/share/icons/hicolor/scalable/apps/hermes-durandal.svg"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
  <rect width="256" height="256" rx="32" fill="#050806"/>
  <path d="M36 214V42l92 58 92-58v172l-40-25V114l-52 33-52-33v75z" fill="none" stroke="#24ff5a" stroke-width="12" stroke-linejoin="round"/>
  <path d="M69 64l59 38 59-38" fill="none" stroke="#ff2b2b" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="128" cy="147" r="18" fill="#ff2b2b"/>
  <path d="M91 202h74" stroke="#24ff5a" stroke-width="10" stroke-linecap="round"/>
  <path d="M56 229h144" stroke="#ff2b2b" stroke-width="6" stroke-linecap="round" opacity="0.85"/>
</svg>
EOF

      cat << 'EOF' > "$HOME/.config/kitty/hermes-durandal.conf"
font_family Roboto Mono
font_size 11.0
background #050806
foreground #24ff5a
cursor #ff2b2b
cursor_text_color #050806
selection_background #183f21
selection_foreground #ffffff
url_color #ff2b2b
active_border_color #24ff5a
inactive_border_color #183f21
bell_border_color #ff2b2b
tab_bar_background #050806
active_tab_background #24ff5a
active_tab_foreground #050806
inactive_tab_background #183f21
inactive_tab_foreground #24ff5a
window_padding_width 8
remember_window_size yes
initial_window_width 120c
initial_window_height 34c
confirm_os_window_close 0
EOF

      cat << 'EOF' > "$HOME/.local/bin/hermes-durandal"
#!/run/current-system/sw/bin/bash
printf '\033[38;2;36;255;90m'
printf 'D U R A N D A L\n'
printf '\033[38;2;255;43;43m'
printf 'Hermes Agent // Marathon terminal uplink\n'
printf '\033[0m\n'
export HERMES_HOME=/var/lib/hermes/.hermes
sleep 0.6
exec /run/current-system/sw/bin/hermes
EOF
      chmod +x "$HOME/.local/bin/hermes-durandal"

      cat << 'EOF' > "$HOME/.local/share/applications/hermes-agent.desktop"
[Desktop Entry]
Name=Durandal
Comment=Launch Hermes Agent in a dedicated Marathon-styled Kitty terminal
Exec=/run/current-system/sw/bin/kitty --config /home/derrik/.config/kitty/hermes-durandal.conf --class durandal,Durandal --title Durandal --working-directory /data/workspace /home/derrik/.local/bin/hermes-durandal
Type=Application
Terminal=false
Icon=hermes-durandal
Categories=Utility;TerminalEmulator;ArtificialIntelligence;
StartupNotify=true
EOF

      $KWRITE --file kglobalshortcutsrc --group "hermes-agent.desktop" --key "_k_friendly_name" "Durandal"
      $KWRITE --file kglobalshortcutsrc --group "hermes-agent.desktop" --key "_launch" "Meta+Alt+H,none,Launch Durandal"
    '';
  };
}
