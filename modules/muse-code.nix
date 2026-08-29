{ config, pkgs, ... }:

let
  muse-update = pkgs.writeShellScriptBin "muse-update" ''
    export MUSE_NO_MODIFY_PATH=1
    export HOME=/home/derrik
    export XDG_CONFIG_HOME=/home/derrik/.config
    curl -fsSL https://dev.meta.ai/install.sh | bash
  '';
in
{
  environment.sessionVariables.PATH = [ "/home/derrik/.local/bin" ];

  systemd.user.services.muse-code-update = {
    description = "Update Muse Code CLI";
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "derrik";
    serviceConfig.Environment = [
      "PATH=/run/current-system/sw/bin:/home/derrik/.local/bin"
      "HOME=/home/derrik"
      "XDG_CONFIG_HOME=/home/derrik/.config"
    ];
    serviceConfig.ExecStart = "${muse-update}/bin/muse-update";
  };

  systemd.user.timers.muse-code-update = {
    description = "Weekly Muse Code update check";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "weekly";
    timerConfig.Persistent = true;
  };
}
