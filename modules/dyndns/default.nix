{ inputs
, config
, pkgs
, lib
, ...
}:
let
  cfg = config.dyndns;
in
{
  options.dyndns = {
    enable = lib.mkOption {
      default = false;
    };
    IPv4 = lib.mkOption {
      default = false;
    };
    IPv6 = lib.mkOption {
      default = false;
    };
    hostname = lib.mkOption {
      default = "";
    };
    zone = lib.mkOption {
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."dyndns/environment" = {
      sopsFile = "${inputs.self}/secrets/common.yaml";
    };

    systemd.timers."dyndns" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "dyndns.service";
      };
    };

    systemd.services."dyndns" = {
      serviceConfig =
        let
          script = pkgs.writeShellApplication {
            name = "dyndns";
            runtimeInputs = with pkgs; [ curl jq ];
            bashOptions = [
              "errexit"
              "pipefail"
            ];
            text = builtins.readFile ./dyndns.sh;
          };
        in
        {
          EnvironmentFile = config.sops.secrets."dyndns/environment".path;
          ExecStart = "${lib.getExe script} ${if cfg.IPv4 then "-4" else ""} ${if cfg.IPv6 then "-6" else ""} -h ${cfg.hostname} -z ${cfg.zone}";
          Type = "oneshot";
          User = "root";
        };
    };
  };
}
