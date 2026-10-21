# Fresh Catppuccin Mocha

`catppuccin-mocha.json` is vendored from
https://github.com/milon/catppuccin-fresh/blob/master/catppuccin-mocha.json.

The `fresh-theme.nix` activation module installs the theme for `derrik` and
selects it in Fresh's configuration on each NixOS rebuild. Other Fresh settings
are preserved. Files are written as the user and remain editable by Fresh.
Restart an already running Fresh instance after rebuilding to load the theme.
